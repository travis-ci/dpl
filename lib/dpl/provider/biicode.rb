require 'mkmf'

module DPL
  class Provider
    class Biicode < Provider

      def self.install_biicode
        unless find_executable 'bii'
		context.shell "wget http://apt.biicode.com/install.sh -O install_biicode.sh && chmod +x install_biicode.sh && ./install_biicode.sh"
      
	end
      end

      install_biicode

      def needs_key?
        false
      end

      def check_app
        raise Error, "must supply a username" unless option(:user)
        raise Error, "must supply a password" unless option(:password)
      end

      def check_auth
        context.shell "bii user #{option(:user)}"
      end

      def push_app
        context.shell "bii publish -p #{option(:password)}"
      end
    end
  end
end
