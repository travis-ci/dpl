module Dpl
  module Providers
    class Npm < Provider
      status :beta

      full_name 'npm'

      description sq(<<-str)
        tbd
      str

      gem 'json'

      env :npm

      opt '--email EMAIL', 'npm account email'
      opt '--api_token TOKEN', 'npm api token', alias: :api_key, required: true, secret: true, note: 'can be retrieved from your local ~/.npmrc file', see: 'https://docs.npmjs.com/creating-and-viewing-authentication-tokens'
      opt '--access ACCESS', 'Access level', enum: %w(public private)
      opt '--registry URL', 'npm registry url'
      opt '--src SRC', 'directory or tarball to publish', default: '.'
      opt '--tag TAGS', 'distribution tags to add'
      opt '--auth_method METHOD', 'Authentication method', enum: %w(auth)

      REGISTRY = 'registry.npmjs.org'
      NPMRC = '~/.npmrc'

      msgs version:  'npm version: %{npm_version}',
           login:    'Authenticated with API token %{api_token}'

      cmds registry: 'npm config set registry "%{registry}"',
           deploy:   'npm publish %{src} %{publish_opts}'

      errs registry: 'Failed to set registry config',
           deploy:    'Failed pushing to npm'

      def login
        info :version
        info :login
        write_npmrc
        shell :registry
      end

      def deploy
        shell :deploy
      end

      def finish
        remove_npmrc
      end

      private

        def publish_opts
          opts_for(%i(access tag))
        end

        def write_npmrc
          write_file(npmrc_path, npmrc)
          info "#{NPMRC} size: #{file_size(npmrc_path)}"
        end

        def remove_npmrc
          rm_f npmrc_path
        end

        def npmrc_path
          expand(NPMRC)
        end

        def npmrc
          if npm_version =~ /^1/ || auth_method == 'auth'
            "_auth = #{api_token}\nemail = #{email}"
          else
            "//#{registry.sub('https://', '').sub(%r(/$), '')}/:_authToken=#{api_token}"
          end
        end

        def registry
          return super if super
          data = package_json
          url = data && data.fetch('publishConfig', {})['registry']
          url ? host(url) : REGISTRY
        end

        def host(url)
          URI(url).host || url
        end

        def package_json
          File.exists?('package.json') ? JSON.parse(File.read('package.json')) : {}
        end
    end
  end
end
