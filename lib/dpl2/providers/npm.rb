module Dpl
  module Providers
    class Npm < Provider
      summary 'Npm deployment provider'

      description <<~str
        tbd
      str

      opt '--email EMAIL', 'NPM email address', required: true
      opt '--api_key KEY', 'NPM api key (can be retrieved from your local ~/.npmrc file)', required: true
      # not mentioned in the readme
      opt '--tag TAGS', 'NPM distribution tags to add'

      REGISTRY = 'registry.npmjs.org'
      NPMRC = '~/.npmrc'

      MSGS = {
        version: 'NPM version: %{npm_version}',
        login:   'Authenticated with email %s and API key %s',
      }

      def login
        info :version
        info :login, email, obfuscate(api_key)
        write_npmrc
      end

      def deploy
        shell "env NPM_API_KEY=#{api_key} npm publish #{opts_for(:tag)}".strip
      end

      def finish
        rm_f npmrc_path
      end

      private

        def write_npmrc
          File.open(npmrc_path, 'w+') { |f| f.write(npmrc) }
          info "#{NPMRC} size: #{File.size(File.expand_path(NPMRC))}"
        end

        def npmrc_path
          File.expand_path(NPMRC)
        end

        def npmrc
          if npm_version =~ /^1/
            "_auth = ${NPM_API_KEY}\nemail = #{email}"
          else
            "//#{registry}/:_authToken=${NPM_API_KEY}"
          end
        end

        def registry
          data = package_json
          url = data && data['publishConfig']&.fetch('registry')
          url ? URI(url).host : REGISTRY
        end

        def package_json
          File.exists?('package.json') ? JSON.parse(File.read('package.json')) : {}
        end
    end
  end
end
