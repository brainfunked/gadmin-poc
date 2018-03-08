require 'gadmin/commands'

module Gadmin
  module Commands
    class Help < Gadmin::Command
      class << self
        def banner(command)
          $gadmin.help
        end
      end
    end
  end
end
