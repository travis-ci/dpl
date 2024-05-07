# frozen_string_literal: true

module Dpl
  module Providers
    class Engineyard < Provider
      register :engineyard

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      gem 'ey-core', '~> 3.6'

      required :api_key, %i[email password]

      env :engineyard, :ey

      opt '--api_key KEY',   'Engine Yard API key', secret: true, note: 'can be obtained at https://cloud.engineyard.com/cli'
      opt '--email EMAIL',   'Engine Yard account email'
      opt '--password PASS', 'Engine Yard password', secret: true
      opt '--app APP',       'Engine Yard application name', default: :repo_name
      opt '--env ENV',       'Engine Yard application environment', alias: :environment
      opt '--migrate CMD',   'Engine Yard migration commands'
      opt '--account NAME',  'Engine Yard account name'

      msgs deploy: 'Deploying ...',
           login: 'Authenticating via email and password ...',
           write_rc: 'Authenticating via api token ...',
           authenticated: 'Authenticated as %{name}',
           invalid_migrate: 'Invalid migration command, try --migrate="rake db:migrate"',
           envs: 'Checking environment ...',
           no_env: 'No matching environment found',
           too_many_envs: 'Multiple environments match, please be more specific: %s',
           env_entry: 'environment=%s account=%s'

      cmds login: "ey-core login << str\n%{email}\n%{password}\nstr",
           whoami: 'ey-core whoami',
           envs: 'ey-core environments',
           deploy: 'ey-core deploy %{deploy_opts}'

      def login
        api_key? ? write_rc : authenticate
        info :authenticated, name: whoami
      end

      def validate
        error :invalid_migrate if invalid_migrate?
        env
      end

      def deploy
        shell :deploy
      end

      private

      def authenticate
        shell :login, echo: false, capture: true
      end

      def whoami
        shell(:whoami, echo: false, capture: true) =~ /email\s*:\s*"(.+)"/ && ::Regexp.last_match(1)
      end

      def write_rc
        info :write_rc
        write_file '~/.ey-core', "https://api.engineyard.com/: #{api_key}"
      end

      def invalid_migrate?
        migrate.is_a?(TrueClass) || migrate == 'true'
      end

      def deploy_opts
        opts = [%(--ref="#{git_sha}" --environment="#{env}")]
        opts << opts_for(%i[app account])
        opts << migrate_opt
        opts.join(' ')
      end

      def migrate_opt
        migrate? ? opts_for(%i[migrate]) : '--no-migrate'
      end

      def env
        @env ||= super || detect_env(envs)
      end

      def detect_env(envs)
        case envs.size
        when 1 then envs.first[:name]
        when 0 then error :no_env
        else too_many_envs(envs)
        end
      end

      def envs
        lines = shell(:envs, echo: false, capture: true).split("\n")[2..] || []
        envs = lines.map { |line| line.split('|')[1..].map(&:strip) }
        envs = envs.map { |pair| %i[name account].zip(pair).to_h }
        envs.select { |env| env[:name] == opts[:env] } if env?
        envs
      end

      def too_many_envs(envs)
        envs = envs.map { |env| msg(:env_entry) % env.values_at(:name, :account) }
        error msg(:too_many_envs) % envs.join(', ')
      end
    end
  end
end
