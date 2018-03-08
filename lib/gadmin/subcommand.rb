require 'slop'

module Gadmin
  class SubCommand
    attr_reader :args, :options, :parser

    def initialize(args = [])
      @options = Slop::Options.new
      define_options
      @parser = Slop::Parser.new @options

      @args = @parser.parse(args) if args
    end

    def help
      puts @options
    end
  end
end
