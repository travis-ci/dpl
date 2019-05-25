module Dpl
  module Providers
    class Rubygems < Provider
      gem 'gems', '~> 1.1.1'

      description sq(<<-str)
        tbd
      str

      required :api_key, [:user, :password]

      opt '--api_key KEY', 'Rubygems api key'
      opt '--gem NAME', 'Name of the gem to release', default: :repo_name
      opt '--gemspec FILE', 'Gemspec file to use to build the gem'
      opt '--gemspec_glob GLOB', 'Glob pattern to search for gemspec files when multiple gems are generated in the repository (overrides the gemspec option)'
      # only mentioned in code
      opt '--username USER', 'Rubygems user name', alias: :user
      opt '--password PASS', 'Rubygems password'
      opt '--host URL'

      msgs login_api_key: 'Authenticating with api key.',
           login_creds:   'Authenticating with username %{username} and password.',
           gem_lookup:    'Looking up gem %{gem} ... ',
           gem_found:     'found.',
           gem_not_found: 'no such gem.',
           gem_push:      'Pushing gem %{gem}'

      cmds gem_build: 'gem build %s'

      errs gem_build: 'Failed to build %s'

      def setup
        Gems.host = host if host?
      end

      def login
        if api_key?
          info :login_api_key
          Gems.key = api_key
        else
          info :login_creds
          Gems.username, Gems.password = username, password
        end
      end

      def validate
        print :gem_lookup
        name = Gems.info(gem)['name']
        info name ? :gem_found : :gem_not_found
      end

      def deploy
        build
        push
      end

      private

        def build
          Dir[gemspec_glob].each do |gemspec|
            shell :gem_build, gemspec, echo: true, assert: true
          end
        end

        def push
          # this seems improvable: if a gemspec_glob has been given it might
          # not match this glob, and not all gems would be pushed
          Dir["#{gem}-*.gem"].each do |file|
            info :gem_push, gem: file
            info Gems.push(File.new(file), *[host])
          end
        end

        def gemspec_glob
          super || "#{gemspec || gem}.gemspec"
        end

        def gemspec
          super.gsub('.gemspec', '') if gemspec?
        end
    end
  end
end
