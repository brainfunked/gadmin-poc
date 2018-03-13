module Gadmin
  class Command
    class << self
      def register!(registry)
        command = self.to_s.split('::')[-1].downcase.to_sym
        registry.register command, self
        puts "%% Registered command '#{command}'"
      end

      def execute(command, subcommand = nil, args = [])
        if subcommand.nil? \
            or [ :help, '--help'.to_sym, '-h'.to_sym ].include? subcommand
          banner command
          return
        end

        begin
          klass = const_get(subcommand.capitalize)
        rescue NameError
          puts "Invalid subcommand: '#{subcommand}'"
          puts
          banner command
          return
        end

        obj = klass.new(subcommand, args)
        puts obj.execute
      end

      def banner(command)
        subcommands = constants.select { |c| const_get(c).is_a? Class }
        subcommands_str = subcommands.collect { |s| s.to_s.split('::')[-1].downcase }
        puts "'#{command}' subcommands: #{subcommands_str.join(', ')}."
        puts "Type `#{command} <subcommand> --help` for help on individual subcommands."
      end
    end
  end
end
