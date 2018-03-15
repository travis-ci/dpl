require 'json'
require 'uri'

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
        file = File.open(File.expand_path(NPMRC_FILE), 'w')
        file.puts(npmrc_file_content)
        file.flush
      end

      def check_auth
        setup_auth
        log "Authenticated with email #{option(:email)} and API key #{option(:api_key)[-4..-1].rjust(20, '*')}"
      end

      def push_app
        log "NPM API key format changed recently. If your deployment fails, check your API key in ~/.npmrc."
        log "http://docs.travis-ci.com/user/deployment/npm/"
        log "#{NPMRC_FILE} size: #{File.size(File.expand_path(NPMRC_FILE))}"

        command = "env NPM_API_KEY=#{option(:api_key)} npm publish"
        command << " --tag #{option(:tag)}" if options[:tag]
        context.shell "#{command}"
        FileUtils.rm(File.expand_path(NPMRC_FILE))
      end

      def package_registry
        if File.exists?('package.json')
          data = JSON.parse(File.read('package.json'))
          if data['publishConfig'] && data['publishConfig']['registry']
            return URI(data['publishConfig']['registry']).host
          end
        end

        DEFAULT_NPM_REGISTRY
      end

      def npmrc_file_content
        log "NPM version: #{npm_version}"
        if npm_version =~ /^1/
          "_auth = ${NPM_API_KEY}\nemail = #{option(:email)}"
        else
          "//#{package_registry}/:_authToken=${NPM_API_KEY}"
        end
      end

      def npm_version
        `npm --version`
      end
    end
  end
end
