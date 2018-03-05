require 'gadmin/cluster_group'
require 'gadmin/commands'
require 'gadmin/commands/help'

module Gadmin
  class Session
    attr_reader :clusters, :registry
    attr_reader :cmd_line, :command, :args

    def initialize
      @clusters = Gadmin::ClusterGroup.new
      @registry = Gadmin::Registry.new

      commands = Gadmin::Commands.constants.select { |c| Gadmin::Commands.const_get(c).is_a? Class }

      commands.each { |c| Gadmin::Commands.const_get(c).register!(@registry) }
    end

    def command(cmd_line)
      @cmd_line = cmd_line
      parse!
    end

    def execute!
      puts "%% Executing '#{@command}' with arguments '#{@args}'."
    end

    private

    def parse!
      cmd_array = @cmd_line.split
      @command  = @registry.commands[cmd_array[0].to_sym]
      @args     = cmd_array[1..cmd_array.length].join
    end
  end
end
