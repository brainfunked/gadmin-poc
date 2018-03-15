module Gadmin
  class Session
    class Command
      class NameError < ::NameError; end

      attr_reader :registry, :cmd_line
      attr_reader :command, :subcommand, :args, :klass

      def initialize(cmd_line, registry)
        @cmd_line = cmd_line
        @registry = registry
        @args     = []
      end

      def execute!
        #puts "%% Executing '#{@command}': subcommand '#{@subcommand}' with arguments '#{@args}'."
        catch :executed do
          catch :helptext do
            @klass.execute @command, @subcommand, @args
          end
        end
      end

      def parse!
        cmd_array = @cmd_line.split
        @command  = cmd_array[0].to_sym
        @klass    = @registry.commands[@command]

        raise NameError unless @klass

        if cmd_array.length > 1
          @subcommand = cmd_array[1].to_sym
          @args       = cmd_array[2..cmd_array.length]
        end

        self
      end
    end
  end
end
