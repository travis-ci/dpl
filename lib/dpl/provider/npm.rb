module DPL
  class Provider
    class NPM < Provider
      NPMRC_FILE = '~/.npmrc'

      def needs_key?
        false
      end

      def check_app
      end

      def setup_auth
        File.open(File.expand_path(NPMRC_FILE), 'w') do |f|
          f.puts("_auth = #{option(:api_key)}")
          f.puts("email = #{option(:email)}")
        end
      end

      def check_auth
        setup_auth
        log "Authenticated with email #{option(:email)}"
      end

      def push_app
        context.shell "npm publish --force"
      end
    end
  end
end
