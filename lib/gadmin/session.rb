require 'gadmin/session/command'

require 'gadmin/cluster_group'
require 'gadmin/commands'
require 'gadmin/commands/help'
require 'gadmin/commands/cluster'

module Gadmin
  class Session
    attr_reader :workdir, :ansible_inventory
    attr_reader :clusters, :registry
    attr_reader :cmd_line, :current

    def initialize(workdir)
      @workdir = workdir
      @ansible_inventory = File.join workdir, 'ansible', 'hosts.yml'

      @clusters = Gadmin::ClusterGroup.new @ansible_inventory

      @registry = Gadmin::Registry.new
      commands = Gadmin::Commands.constants.select { |c| Gadmin::Commands.const_get(c).is_a? Class }
      commands.each { |c| Gadmin::Commands.const_get(c).register!(@registry) }

      @started = false
    end

    def start!
      return if started?
      @clusters.load_clusters
      started!

      self
    rescue Exception => e
      puts "Unable to load clusters: #{e.message}"
      puts "\t#{e.backtrace.join("\n\t")}"
    end

    def command(cmd_line)
      @current = Gadmin::Session::Command.new(cmd_line, @registry)
    end

    def execute
      catch :helptext do
        @current.parse!.execute!
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

    private

    def started!
      @started = true
    end

    def reset!
      @current = nil
    end
  end
end
