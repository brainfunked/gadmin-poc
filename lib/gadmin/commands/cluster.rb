require 'gadmin/commands'

module Gadmin
  module Commands
    class Cluster < Gadmin::Command
      class Define < Gadmin::SubCommand
        def execute

        end

        private

        def define_options
          @options.banner = 'Usage: cluster define --peers <192.168.1.1,192.168.1.2,..>'
          @options.separator ''
          @options.array '--peers', 'comma delimited list of peers (no spaces)'
          @options
        end
      end
    end
  end
end
