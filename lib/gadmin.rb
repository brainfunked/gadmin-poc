module Gadmin
  class Registry
    attr_reader :commands

    def initialize
      @commands = Hash.new
    end

    def register(cmd, klass)
      @commands[cmd.to_sym] = klass
    end

    def command_list
      @commands.keys.join ", "
    end
  end
end
