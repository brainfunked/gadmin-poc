require 'gadmin/commands'

module Gadmin
  module Commands
    class Help < Gadmin::Command
      class << self
        def help(command, subcommand = nil)
          $gadmin.help
        end
      end
    end
  end
end
