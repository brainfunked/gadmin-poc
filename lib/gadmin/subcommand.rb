require 'slop'

module Gadmin
  class SubCommand
    class ValidationError < ::SyntaxError; end

    attr_reader :subcommand, :args, :options, :parser_options, :parser

    def initialize(subcommand, args = [])
      @subcommand     = subcommand
      @args           = args
      @parser_options = Slop::Options.new
      @parser_options.bool '-h', '--help', 'Print this help text.', default: false
      define_parser_options
      @parser         = Slop::Parser.new @parser_options
    end

    def execute
      parse!
      if help?
        help
        throw :helptext
      end
      validate!
      execute!
      throw :executed
    rescue Slop::UnknownOption => e
      puts "Invalid option for subcommand '#{subcommand}': #{e.flag}"
      puts
      help
    rescue Gadmin::SubCommand::ValidationError => e
      puts "Invalid input for subcommand '#{subcommand}': #{e.message}"
      puts
      help
    end

    def help
      puts @parser_options
    end

    private

    def define_parser_options
      @parser_options
    end

    def validate!
    end

    def parse!
      @options = @parser.parse @args
    end

    def help?
      if @options
        return true if @options.arguments.include? 'help' or @options.help?
      end

      false
    end
  end
end
