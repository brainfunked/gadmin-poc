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
        return
      end

      select_cluster
      started!

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
      catch :helptext do
        @current.command.parse!.execute!
      end
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
      selection = TTY::Prompt.new.select "Select cluster:", @clusters.list
      @current.cluster = @clusters[selection]
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
