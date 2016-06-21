module DPL
  class Provider
    class Maven < Provider

      def needs_key?
        false
      end

      def check_app
      end

      def setup_auth
      end

      def check_auth
      end

      def secret_key_file
        options[:secret_key_file]|| raise(Error, "missing secret_key_file")
      end

      def gpg_passphrase
        options[:gpg_passphrase]|| raise(Error, "missing gpg_passphrase")
      end

      def id
        options[:id]|| raise(Error, "missing id")
      end

      def url
        options[:url]|| raise(Error, "missing url")
      end

      def push_app
        context.shell "gpg --import #{secret_key_file()}"
        context.shell "mvn verify gpg:sign deploy:deploy -Dgpg.passphrase=#{gpg_passphrase()} -DaltDeploymentRepository=#{id()}::default::#{url()}"
      end
    end
  end
end
