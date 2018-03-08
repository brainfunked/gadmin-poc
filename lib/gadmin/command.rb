module Gadmin
  class Command
    class << self
      def register!(registry)
        command = self.to_s.split('::')[-1].downcase.to_sym
        registry.register command, self
        puts "%% Registered command '#{command}'"
      end

      def execute(command, subcommand = nil, args = [])
        unless subcommand
          help command
          return
        end

        begin
          obj = const_get(subcommand.capitalize)
        rescue NameError
          raise NameError, "No such command: '#{subcommand}'"
        end

        obj.new(args)
      end

      def help(command, subcommand = nil)
        unless subcommand
          banner command
          return
        end

        begin
          obj = const_get(subcommand.capitalize)
        rescue NameError
          raise NameError, "No such command: '#{subcommand}'"
        end

        obj.new.help
      end

      def banner(command)
        subcommands = constants.select { |c| const_get(c).is_a? Class }
        subcommands_str = subcommands.collect { |s| s.to_s.split('::')[-1].downcase }
        puts "'#{command}' subcommands: #{subcommands_str.join(', ')}."
      end
    end
  end
end
