module Dpl
  module Providers
    class Now < Provider
      status :dev

      description sq(<<-str)
        tbd
      str

      npm 'now'

      env 'now'

      opt '--token TOKEN',      'Now token', required: true, secret: true, see: 'https://zeit.co/account/tokens'
      opt '--name NAME',        'Name of the deployment', default: :repo_name
      opt '--dir DIR',          'Directory to deploy from', default: '.'
      opt '--team TEAM',        'Team scope'
      opt '--type TYPE',        'Deployment type', enum: %w(docker npm static)
      opt '--alias ALIAS',      'Alias name', eg: 'alias.now.sh', see: 'https://zeit.co/docs/features/aliases'
      opt '--rm',               'Clean up old deployments', requires: :alias, see: 'https://zeit.co/docs/other/faq#how-do-i-remove-an-old-deployment'
      opt '--rules_domain STR', 'Custom path aliases', requires: :rules_file, see: 'https://zeit.co/docs/features/path-aliases'
      opt '--rules_file PAHT',  'Rules file', default: 'rules.json'
      opt '--scale OPTS',       'Scaling options', see: 'https://zeit.co/docs/getting-started/scaling'

      cmds deploy:  'now %{auth_opts} %{deploy_opts} %{dir}',
           rm:      'now rm --safe --yes %{auth_opts} %{alias}',
           alias:   'now alias %{auth_opts} %{url} %{alias}',
           scale:   'now scale %{auth_opts} %{url} %{scale}',
           rules:   'now alias %{auth_opts} %{rules_domain} -r %{rules_file}'

      msgs deploy:  'Deploying %{dir} on now.sh ...',
           rm:      'Cleaning up old deployments ...',
           alias:   'Assigning alias %{alias} to %{url} ...',
           scale:   'Scaling to %{scale} ...',
           rules:   'Assigning domain rules ...',
           success: 'Successfully deployed: %{url}'

      attr_reader :url

      def deploy
        @url = shell :deploy, capture: true
        shell :rm    if rm?
        alias_url    if alias?
        shell :scale if scale?
        shell :rules if rules?
        info :success
      end

      def alias_url
        shell :alias
        @url = "https://#{self.alias}"
      end

      def alias
        super.sub(%r(^https?://), '')
      end

      def dir
        expand(super)
      end

      def rules?
        rules_domain? && rules_file?
      end

      def auth_opts
        opts_for(%i(token team))
      end

      def deploy_opts
        opts = [*opts_for(%i(name)), '--no-clipboard']
        opts << "--#{type}" if type?
        opts.join(' ')
      end
    end
  end
end
