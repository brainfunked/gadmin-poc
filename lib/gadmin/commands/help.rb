module Gadmin
  module Commands
    class Help
      def self.register!(registry)
        registry.register :help, self
        puts "%% Registered command 'help'"
      end
    end
  end
end
