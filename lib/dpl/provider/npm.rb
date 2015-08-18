require 'json'

module DPL
  class Provider
    class NPM < Provider
      NPMRC_FILE = '~/.npmrc'
      DEFAULT_NPM_REGISTRY = 'registry.npmjs.org'

      def needs_key?
        false
      end

      def check_app
      end

      def setup_auth
        f = File.open(File.expand_path(NPMRC_FILE), 'w')
        f.puts("//#{package_registry}/:_authToken=${NPM_API_KEY}")
      end

      def check_auth
        setup_auth
        log "Authenticated with email #{option(:email)}"
      end

      def push_app
        log "NPM API key format changed recently. If your deployment fails, check your API key in ~/.npmrc."
        log "http://docs.travis-ci.com/user/deployment/npm/"
        context.shell "env NPM_API_KEY=#{option(:api_key)} npm publish"
        FileUtils.rm(File.expand_path(NPMRC_FILE))
      end

      def package_registry
        if File.exists?('package.json')
          data = JSON.parse(File.read('package.json'))
          if data['publishConfig'] && data['publishConfig']['registry']
            return data['publishConfig']['registry']
          end
        end

        DEFAULT_NPM_REGISTRY
      end
    end
  end
end
