module Dpl
  module Providers
    class Hephy < Provider
      description sq(<<-str)
        tbd
      str

      opt '--controller NAME', 'Hephy controller', required: true, example: 'hephy.hephyapps.com'
      opt '--username USER',   'Hephy username', required: true
      opt '--password PASS',   'Hephy password', required: true, secret: true
      opt '--app APP',         'Deis app', required: true
      opt '--cli_version VER', 'Install a specific hephy cli version', default: 'stable'
      opt '--verbose',         'Verbose log output'

      needs :git, :ssh_key
      path '~/.dpl'

      INSTALL = 'https://raw.githubusercontent.com/teamhephy/workflow-cli/master/install-v2.sh'

      # curl -sL https://raw.githubusercontent.com/teamhephy/workflow-cli/master/install-v2.sh | bash -s v2.20.0 && sudo mv deis /usr/local/bin/

      cmds install:    'curl -sSL %{INSTALL} | bash -x -s %{cli_version} && mv deis ~/.dpl',
           login:      'deis login %{controller} --username=%{username} --password=%{password}',
           add_key:    'deis keys:add %{key}',
           validate:   'deis apps:info --app=%{app}',
           deploy:     'git push %{verbose} %{url} HEAD:refs/heads/master -f',
           run:        'deis run -a %{app} -- %{cmd}',
           remove_key: 'deis keys:remove %{key_name}'

      errs login:      'Login failed.',
           add_key:    'Adding keys failed.',
           validate:   'Application could not be verified.',
           deploy:     'Deploying application failed.',
           run:        'Running command failed.',
           remove_key: 'Removing keys failed.'

      def install
        shell :install
      end

      def login
        shell :login
      end

      def add_key(key)
        shell :add_key, key: key
        wait_for_ssh_access(host, port)
      end

      def validate
        shell :validate
      end

      def deploy
        shell :deploy
      end

      def run_cmd(cmd)
        shell :run, app: app, cmd: cmd
      end

      def remove_key
        shell :remove_key
      end

      def verbose
        verbose? ? '-v' : ''
      end

      def host
        url.host
      end

      def port
        url.port
      end

      def url
        @url ||= URI.parse("ssh://git@#{builder}:2222/#{app}.git")
      end

      def builder
        parts = host.split('.')
        parts[0] = [parts[0], 'builder'].join('-')
        parts.join('.')
      end

      def host
        controller.gsub(/https?:\/\//, '').split(':')[0]
      end
    end
  end
end
