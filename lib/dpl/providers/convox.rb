# frozen_string_literal: true

module Dpl
  module Providers
    class Convox < Provider
      register :convox

      status :dev

      description sq(<<-STR)
        tbd
      STR

      gem 'json'

      env :convox

      # needs descriptions
      opt '--host HOST', default: 'console.convox.com'
      opt '--app APP', required: true
      opt '--rack RACK', required: true
      opt '--password PASS', required: true
      opt '--install_url URL', default: 'https://convox.com/cli/linux/convox'
      opt '--update_cli'
      opt '--create'
      opt '--promote', default: true
      opt '--env_names VARS', type: :array, sep: ','
      opt '--env VARS', type: :array
      opt '--env_file FILE'
      opt '--description STR'
      opt '--generation NUM', type: :int, default: '2'
      opt '--prepare CMDS', 'Run commands with convox cli available just before deployment', type: :array

      # if app and rack are exported to the env, do they need to be passed to these commands?
      cmds login: 'convox version --rack %{rack}',
           validate: 'convox apps info --rack %{rack} --app %{app}',
           create: 'convox apps create %{app} --generation %{generation} --rack %{rack} --wait',
           update: 'convox update',
           set_env: 'convox env set %{env} --rack %{rack} --app %{app} --replace',
           build: 'convox build --rack %{rack} --app %{app} --id --description %{escaped_description}',
           deploy: 'convox deploy --rack %{rack} --app %{app} --wait --id --description %{escaped_description}'

      msgs create: 'Application %{app} does not exist on rack %{rack}. Creating it ...',
           missing: 'Application %{app} does not exist on rack %{rack}.',
           env_file: 'The given env_file does not exist.',
           deploy: 'Building and promoting application ...',
           build: 'Building application ...'

      errs login: 'Login failed.'

      def install
        script :install
        shell :update if update_cli?
        export
      end

      def login
        shell :login
      end

      def validate
        shell :validate, assert: false and return
        error :missing unless create?
        shell :create
      end

      def prepare
        Array(super).each do |cmd|
          cmd.casecmp('restart').zero? ? restart : run_cmd(cmd)
        end
      end

      def deploy
        shell :set_env, echo: false unless env.empty?
        shell promote? ? :deploy : :build, echo: false
      end

      def env_names
        env = super || []
        env = env.map { |str| "#{str}=#{ENV[str]}" }
        env_file.concat(env)
      end

      def env
        env = env_names.concat(super || [])
        env.map { |str| escape(str) }.join(' ')
      end

      def env_file
        return [] unless env_file?

        error :env_file unless file?(super)
        lines = read(super).split("\n").map(&:strip)
        lines.reject(&:empty?)
      end

      def description
        if description?
          super
        else
          JSON.dump(
            repo_slug:,
            git_commit_sha: git_sha,
            git_commit_message: git_commit_msg,
            git_commit_author: git_author_name,
            git_tag:,
            branch: git_branch,
            travis_build_id: ENV['TRAVIS_BUILD_ID'],
            travis_build_number: ENV['TRAVIS_BUILD_NUMBER'],
            pull_request: ENV['TRAVIS_PULL_REQUEST']
          )
        end
      end

      def export
        env_vars.each { |key, value| ENV[key.to_s] = value.to_s }
      end

      def env_vars
        {
          CONVOX_HOST: host,
          CONVOX_PASSWORD: password,
          CONVOX_APP: app,
          CONVOX_RACK: rack,
          CONVOX_CLI: 'convox'
        }
      end
    end
  end
end
