require 'gadmin/commands'

module Gadmin
  module Commands
    class Cluster < Gadmin::Command
      class Define < Gadmin::SubCommand
        def execute
          super
        end

        private

        def validate!
          raise Gadmin::SubCommand::ValidationError, "'--name' must be a string." if @options[:name].nil? or @options[:name].empty? 
          raise Gadmin::SubCommand::ValidationError, "'--peers' must be a list of hosts." if @options[:peers].empty?
        end

        def define_parser_options
          @parser_options.banner = 'Usage: cluster define --peers <192.168.1.1,192.168.1.2,..>'
          @parser_options.separator ''
          @parser_options.string '--name', 'Name for the cluster.'
          @parser_options.array '--peers', 'Comma delimited list of peers (no spaces).'
          @parser_options
        end
      end
    end
  end
end
