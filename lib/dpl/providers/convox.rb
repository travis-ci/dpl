module Dpl
  module Providers
    class Convox < Provider
      status :dev

      description sq(<<-str)
        tbd
      str

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
      opt '--env VARS', type: :array
      opt '--env_file FILE'
      opt '--description STR'
      opt '--generation NUM', type: :int, default: '2'
      opt '--prepare CMDS', 'Run commands with convox cli available just before deployment', type: :array

      # if app and rack are exported to the env, do they need to be passed to these commands?
      cmds login:    'convox version --rack %{rack}',
           validate: 'convox apps info --rack %{rack} --app %{app}',
           create:   'convox apps create %{app} --generation %{generation} --rack %{rack} --wait',
           update:   'convox update',
           set_env:  'convox env set %{env} --rack %{rack} --app %{app} --replace',
           build:    'convox build --rack %{rack} --app %{app} --id --description %{escaped_description}',
           deploy:   'convox deploy --rack %{rack} --app %{app} --wait --id --description %{escaped_description}'

      msgs create:   'Application %{app} does not exist on rack %{rack}. Creating it ...',
           missing:  'Application %{app} does not exist on rack %{rack}.',
           env_file: 'The given env_file does not exist.',
           deploy:   'Building and promoting application ...',
           build:    'Building application ...'

      errs login:    'Login failed.'

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

      # not sure about this api. i like that there is an api for people to include
      # env vars from the current build env, but maybe it would be better to expose
      # FOO=$FOO? is mapping a bare env key to a key/value pair a concept in convox?
      #
      # def env
      #   env = env_file.concat(super || []) # TODO Cl should return an empty array, shouldn't it?
      #   env = env.map { |str| str.include?('=') ? str : "#{str}=#{ENV[str]}" }
      #   env.map { |str| escape(str) }.join(' ')
      # end

      # here's an alternative implementation that would expose FOO=$FOO:
      gem 'sh_vars', '~> 1.0.2'

      def env
        env = env_file.concat(super || [])
        env = env.map { |str| ShVars.parse(str).to_h }.inject(&:merge) || {}
        env.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
      end

      def env_file
        return [] unless env_file?
        error :env_file unless file?(super)
        lines = read(super).split("\n").map(&:strip)
        lines.reject(&:empty?)
      end

      def description
        description? ? super : JSON.dump(
          repo_slug: repo_slug,
          git_commit_sha: git_sha,
          git_commit_message: git_commit_msg,
          git_commit_author: git_author_name,
          git_tag: git_tag,
          branch: git_branch,
          travis_build_id: ENV['TRAVIS_BUILD_ID'],
          travis_build_number: ENV['TRAVIS_BUILD_NUMBER'],
          pull_request: ENV['TRAVIS_PULL_REQUEST']
        )
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
