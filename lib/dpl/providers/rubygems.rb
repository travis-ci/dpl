# frozen_string_literal: true

module Dpl
  module Providers
    class Rubygems < Provider
      register :rubygems

      status :stable

      description sq(<<-STR)
        tbd
      STR

      gem 'gems', '~> 1.1.1'

      env :rubygems

      required :api_key, %i[username password]

      opt '--api_key KEY', 'Rubygems api key', secret: true
      opt '--username USER', 'Rubygems user name', alias: :user
      opt '--password PASS', 'Rubygems password', secret: true
      opt '--gem NAME', 'Name of the gem to release', default: :repo_name
      opt '--gemspec FILE', 'Gemspec file to use to build the gem'
      opt '--gemspec_glob GLOB', 'Glob pattern to search for gemspec files when multiple gems are generated in the repository (overrides the gemspec option)'
      opt '--host URL'

      msgs login_api_key: 'Authenticating with api key %{api_key}',
           login_creds: 'Authenticating with username %{username} and password %{password}',
           setup: 'Setting up host %{host}',
           gem_lookup: 'Looking up gem %{gem} ... ',
           gem_found: 'found.',
           gem_not_found: 'no such gem.',
           gem_push: 'Pushing gem %{gem}'

      cmds gem_build: 'gem build %{gemspec}'

      errs gem_build: 'Failed to build %{gemspec}'

      def setup
        return unless host?

        info :setup
        Gems.host = host
      end

      def login
        api_key? ? login_api_key : login_creds
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

      def login_api_key
        info :login_api_key
        Gems.key = api_key
      end

      def login_creds
        info :login_creds
        Gems.username = username
        Gems.password = password
      end

      def build
        Dir[gemspec_glob].each do |gemspec|
          shell :gem_build, gemspec: gemspec.whitelist
        end
      end

      def push
        Dir["#{gem}-*.gem"].each do |file|
          info :gem_push, gem: file.whitelist
          info Gems.push(File.new(file), *[host].compact)
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
