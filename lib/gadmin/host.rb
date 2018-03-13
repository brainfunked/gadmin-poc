module Gadmin
  class Host
    attr_reader :hostname, :roles

    def initialize(hostname, *roles)
      @hostname = hostname
      @roles    = Roles.new roles
    end

    class Roles
      def initialize(*roles)
        @roles = roles.flatten.uniq
      end

      def add(*roles)
        @roles.push roles
        @roles.flatten!.uniq!
      end

      def list
        @roles.dup
      end
    end
  end
end
