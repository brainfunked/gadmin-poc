require 'gadmin/session/command'

require 'gadmin/cluster_group'
require 'gadmin/commands'
require 'gadmin/commands/help'
require 'gadmin/commands/cluster'

module Gadmin
  class Session
    attr_reader :clusters, :registry
    attr_reader :cmd_line, :current

    def initialize
      @clusters = Gadmin::ClusterGroup.new
      @registry = Gadmin::Registry.new

      commands = Gadmin::Commands.constants.select { |c| Gadmin::Commands.const_get(c).is_a? Class }

      commands.each { |c| Gadmin::Commands.const_get(c).register!(@registry) }
    end

    def command(cmd_line)
      @current = Gadmin::Session::Command.new(cmd_line, @registry)
    end

    def execute
      @current.parse!.execute!
      reset!
    rescue Command::NameError
      puts "Invalid command '#{@current.command}'"
      help
    end

    def help
      puts "Available commands: #{@registry.command_list}."
      puts "Type `<command> help` for help on individual commands."
    end

    private

    def reset!
      @current = nil
    end
  end
end
