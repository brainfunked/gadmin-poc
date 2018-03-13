require 'gadmin/host'

module Gadmin
  class Cluster
    class NoPeersInInventory < ::ArgumentError; end
    class InventoryNotParsed < ::RuntimeError; end

    attr_reader :name, :hosts, :roles

    def initialize(name, inventory)
      @name = name
      @inventory = inventory

      @hosts  = {}
      @roles  = []

      @loaded = false
      @parsed = false

      @host_data = {}
      @role_data = {}
    end

    def load_cluster
      return self if loaded?
      load_cluster!
    end

    def loaded?
      @loaded
    end

    def parsed?
      @parsed
    end

    private

    def load_cluster!
      parse_inventory!
      load_peers_from_inventory
      load_roles_from_inventory

      loaded!
      destroy_inventory_data!

      self
    end

    def loaded!
      @loaded = true
    end

    def parsed!
      @parsed = true
    end

    def parse_inventory!
      raise NoPeersInInventory, "No peers in the inventory for #@name." if @inventory['hosts'].nil? and not @inventory['hosts'].is_a? Hash

      # Populates the list of hosts and roles from the inventory
      @inventory['hosts'].each do |hostname, data|
        @hosts[hostname] = nil
        @host_data[hostname] = data
      end

      if @inventory['children']
        @inventory['children'].each do |role, data|
          @roles.push role.to_sym
          @role_data[role.to_sym] = data
        end

        @roles.flatten!

        hostnames = @hosts.keys
        @role_data.each do |role, data|
          hosts = data['hosts']
          if hosts
            hosts.each do |hostname, value|
              @hosts[hostname] = nil unless hostnames.include? hostname
            end
          end
        end
      end

      parsed!
    end

    def load_peers_from_inventory
      raise InventoryNotParsed unless parsed?

      @host_data.each do |k, v|
        next if @hosts[k].is_a? Gadmin::Host and @hosts[k].hostname == k
        @hosts[k] = Gadmin::Host.new k, :peer
      end
    end

    def load_roles_from_inventory
      raise InventoryNotParsed unless parsed?

      @role_data.each do |role, data|
        data['hosts'].keys.each do |hostname|
          @hosts[hostname].roles.add role if @hosts[hostname].is_a? Gadmin::Host and @hosts[hostname].hostname == hostname
        end
      end
    end

    def destroy_inventory_data!
      [ :@inventory, :@host_data, :@role_data ].each { |var| remove_instance_variable var }
    end
  end
end
