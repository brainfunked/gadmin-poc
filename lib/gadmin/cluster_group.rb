require 'gadmin/cluster'

require 'forwardable'
require 'yaml'

module Gadmin
  class ClusterGroup
    extend Forwardable

    def_delegator :@clusters, :[]

    attr_reader :inventory_files, :clusters

    def initialize(inventory)
      @inventory_files = []
      Dir.foreach(inventory) do |file|
        file_path = File.expand_path(File.join(inventory, file))
        @inventory_files.push(file_path) unless Dir.exist?(file_path)
      end

      @clusters = {}

      @loaded = false
    end

    def load_clusters
      return if loaded?

      @inventory_files.each do |file|
        inventory = YAML.load_file(file)['all']['children']['gadmin']['children']
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
