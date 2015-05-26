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
          f.puts("_auth = ${NPM_API_KEY}")
          f.puts("email = #{option(:email)}")
        end
      end

      def check_auth
        setup_auth
        log "Authenticated with email #{option(:email)}"
      end

      def push_app
        context.shell "env NPM_API_KEY=#{option(:api_key)} npm publish"
      end
    end
  end
end
