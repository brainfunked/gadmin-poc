require 'gadmin/cluster_group'
require 'gadmin/commands'
require 'gadmin/commands/help'
require 'gadmin/commands/cluster'

module Gadmin
  class Session
    attr_reader :clusters, :registry
    attr_reader :cmd_line, :command, :subcommand, :args

    def initialize
      @clusters = Gadmin::ClusterGroup.new
      @registry = Gadmin::Registry.new

      @args     = []

      commands = Gadmin::Commands.constants.select { |c| Gadmin::Commands.const_get(c).is_a? Class }

      commands.each { |c| Gadmin::Commands.const_get(c).register!(@registry) }
    end

    def command(cmd_line)
      @cmd_line = cmd_line
      parse!
    end

    def execute!
      # puts "%% Executing '#{@command}': subcommand '#{@subcommand}' with arguments '#{@args}'."

      unless @klass
        puts "Invalid command '#@command'.\n\n"
        help
        return
      end

      @klass.execute @command, @subcommand, @args
    end

    def help
      puts "%% Available commands: #{@registry.command_list}."
      puts "%% Type `<command> help` for help on individual commands."
    end

    private

    def parse!
      cmd_array = @cmd_line.split
      @command  = cmd_array[0].to_sym
      @klass    = @registry.commands[@command]

      if cmd_array.length > 1
        @subcommand = cmd_array[1].to_sym
        @args       = cmd_array[2..cmd_array.length]
      end
    end
  end
end
