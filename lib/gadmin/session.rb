require 'gadmin'

require 'gadmin/cluster_group'

require 'gadmin/session/command'

require 'gadmin/commands'
require 'gadmin/commands/help'
require 'gadmin/commands/cluster'

require 'singleton'
require 'forwardable'

require 'tty-prompt'

module Gadmin
  class Session
    class Store
      include Singleton

      attr_accessor :cluster, :command
    end

    extend Forwardable

    def_delegators :@current, :cluster, :command

    attr_reader :workdir, :ansible_inventory
    attr_reader :clusters, :registry

    def initialize(workdir)
      @workdir = workdir
      @ansible_inventory = File.join workdir, 'ansible', 'inventory'

      @clusters = Gadmin::ClusterGroup.new @ansible_inventory

      @registry = Gadmin::Registry.new
      commands = Gadmin::Commands.constants.select { |c| Gadmin::Commands.const_get(c).is_a? Class }
      commands.each { |c| Gadmin::Commands.const_get(c).register!(@registry) }

      @current = Store.instance

      @started = false
    end

    def start!
      return if started?

      @clusters.load_clusters
      if @clusters.list.empty?
        puts "No clusters defined, please define one using `cluster define`"
        return self
      end

      select_cluster
      started! if cluster_selected?

      self
    rescue Exception => e
      puts "Unable to load clusters: #{e.message}"
      puts "\t#{e.backtrace.join("\n\t")}"
    end

    def prep(cmd_line)
      @current.command = Gadmin::Session::Command.new(cmd_line, @registry)
      self
    end

    def execute
      selection_triggered = catch :select_cluster do
        new_cluster = catch :cluster_added do
          @current.command.parse!.execute!
        end
        @clusters.add new_cluster if new_cluster
        throw :select_cluster, true if @clusters.count == 1
      end
      select_cluster if selection_triggered == true
      reset!
    rescue Command::NameError
      puts "Invalid command '#{@current.command}'"
      help
    end

    def help
      puts "Available commands: #{@registry.command_list}."
      puts "Type `<command> --help` for help on individual commands."
    end

    def started?
      @started
    end

    def select_cluster
      selection = @clusters.count == 1 ? @clusters.list.first : TTY::Prompt.new.select("Select cluster:", @clusters.list)
      puts "Selecting cluster '#{selection}'"
      @current.cluster = @clusters[selection]

      started!
    end

    def cluster_selected?
      @current.cluster.is_a? Gadmin::Cluster
    end

    def cluster_exists?(name)
      @clusters.named? name
    end

    private

    def started!
      @started = true
    end

    def reset!
      @current.command = nil
    end
  end
end
