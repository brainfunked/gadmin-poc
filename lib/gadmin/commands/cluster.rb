require 'gadmin/commands'

require 'yaml'

module Gadmin
  module Commands
    class Cluster < Gadmin::Command
      class Define < Gadmin::SubCommand
        attr_reader :inventory

        def initialize(subcommand, args = [])
          super

          @inventory = {
            "all" => {
              "children" => {
                "gadmin" => {
                  "children" => {
                  }
                }
              }
            }
          }
        end

        def execute!
          assemble_inventory
          write_inventory!

          throw :cluster_added, @options[:name]
        end

        def assemble_inventory
          # Bah! This whole thing should be handled via an Inventory class
          # instead of this messed up hash juggling
          cluster = {}

          peer_hosts = {}
          @options[:peers].each { |name| peer_hosts[name] = nil }
          cluster["hosts"] = peer_hosts

          cluster["children"] = {} unless @options[:smb].empty? and @options[:monitoring].nil?

          unless @options[:smb].empty?
            smb_hosts = { "hosts" => {} }
            @options[:smb].each { |name| smb_hosts["hosts"][name] = nil }
            cluster["children"]["smb"] = smb_hosts
          end

          unless @options[:monitoring].nil?
            cluster["children"]["monitoring"] = { "hosts" => { options[:monitoring] => nil } }
          end

          @inventory["all"]["children"]["gadmin"]["children"][@options[:name]] = cluster
        end

        def write_inventory!
          inventory_file = File.join $gadmin.ansible_inventory, @options[:name]
          File.open(inventory_file, 'w') do |file|
            file.write @inventory.to_yaml
          end

          puts "Added cluster '#{@options[:name]}' to ansible inventory"
        end

        private

        def validate!
          raise Gadmin::SubCommand::ValidationError, "'--name' must be a string." if\
            @options[:name].nil? or @options[:name].empty?
          raise Gadmin::SubCommand::ValidationError, "Cluster named '#{@options[:name]}' already exists." if\
            $gadmin.cluster_exists?(@options[:name])
          raise Gadmin::SubCommand::ValidationError, "'--peers' must be a list of hosts." if\
            @options[:peers].empty?
          raise Gadmin::SubCommand::ValidationError, "'--monitoring' must be a single host." if\
            @options[:monitoring] and @options[:monitoring].split(',').length > 1
        end

        def define_parser_options
          @parser_options.banner = 'Define a new cluster and load it.' + "\nUsage: cluster define --peers <192.168.1.1,192.168.1.2,..>"
          @parser_options.separator ''
          @parser_options.string '--name', 'Unique name for the cluster.'
          @parser_options.array '--peers', 'Comma delimited list of peers (no spaces).'
          @parser_options.array '--smb', "Comma delimited list of smb hosts (no spaces). smb hosts don't need to be peers."
          @parser_options.string '--monitoring', "Monitoring host. Doesn't need to be a peer."
          @parser_options
        end
      end

      class List < Gadmin::SubCommand
        def execute!
          puts "Loaded clusters:"
          puts "\t- #{$gadmin.clusters.list.join("\n\t- ")}"
        end

        private

        def define_parser_options
          @parser_options.banner = 'List loaded clusters.' + "\nUsage: cluster list"
          @parser_options
        end
      end

      class Select < Gadmin::SubCommand
        def execute!
          throw :select_cluster, true
        end

        private

        def define_parser_options
          @parser_options.banner = 'Select a cluster to operate upon from the list of loaded clusters.' + "\nUsage: cluster select"
          @parser_options
        end
      end
    end
  end
end
