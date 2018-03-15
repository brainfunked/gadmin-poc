require 'gadmin/cluster'

require 'forwardable'
require 'yaml'

module Gadmin
  class ClusterGroup
    extend Forwardable

    def_delegator :@clusters, :[]

    attr_reader :inventory, :inventory_files, :clusters

    def initialize(inventory)
      @inventory = inventory
      @inventory_files = []
      Dir.foreach(inventory) do |file|
        file_path = inventory_file_path file
        @inventory_files.push(file_path) unless Dir.exist?(file_path)
      end

      @clusters = {}

      @loaded = false
    end

    def load_clusters
      return if loaded?

      @inventory_files.each do |file|
        inventory = load_inventory_file file
        inventory.each { |name, data| load_cluster name, data }
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

    def count
      @clusters.count
    end

    def named?(name)
      @clusters.keys.include? name
    end

    def add(cluster_name)
      inventory = load_inventory_file(inventory_file_path(cluster_name))
      inventory.each { |name, data| load_cluster name, data }

      loaded!

      @clusters[cluster_name]
    end

    private

    def inventory_file_path(file)
      File.expand_path(File.join(@inventory, file))
    end

    def load_inventory_file(file)
      YAML.load_file(file)['all']['children']['gadmin']['children']
    end

    def load_cluster(name, data)
      @clusters[name] = Gadmin::Cluster.new(name, data).load_cluster

      puts "%% Loaded cluster '#{name}'"
    rescue Gadmin::Cluster::NoPeersInInventory => e
      puts e.message
    rescue => e
      puts "Something went wrong when loading cluster '#{name}': #{e.message}"
      puts "\t#{e.backtrace.join("\n\t")}"
    end

    def loaded!
      @loaded = true
    end
  end
end
