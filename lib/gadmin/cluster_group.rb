require 'gadmin/cluster'

require 'forwardable'
require 'yaml'

module Gadmin
  class ClusterGroup
    extend Forwardable

    def_delegator :@clusters, :[]

    attr_reader :inventory_file, :clusters

    def initialize(inventory_file)
      @inventory_file = inventory_file
      @clusters = {}

      @loaded = false
    end

    def load_clusters
      return if loaded?
      inventory = YAML.load_file(@inventory_file)['all']['children']['gadmin']['children']
      inventory.each do |name, data|
        begin
          @clusters[name] = Gadmin::Cluster.new(name, data).load_cluster

          puts "%% Loaded cluster '#{name}'"
        rescue Gadmin::Cluster::NoPeersInInventory => e
          puts e.message
        rescue => e
          puts "Something went wrong when loading cluster '#{name}': #{e.message}"
          puts "\t#{e.backtrace.join("\n\t")}"
        end
      end

      loaded!

      self
    end

    def loaded?
      @loaded
    end

    def list
      @clusters.keys
    end

    private

    def loaded!
      @loaded = true
    end
  end
end
