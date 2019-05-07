module Dpl
  module Providers
    class Anynines < Provider
      summary 'Anynines deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER',    'anynines username', required: true
      opt '--password PASS',    'anynines password', required: true
      opt '--organization ORG', 'anynines target organization', required: true
      opt '--space SPACE',      'anynines target space', required: true
      opt '--app_name APP',     'Application name'
      opt '--manifest FILE',    'Path to the manifest'

      API = 'https://api.aws.ie.a9s.eu'

      def install
        shell 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz'
      end

      def check_auth
        shell "./cf api #{API}"
        shell "./cf login -u #{username} -p #{password} -o #{organization} -s #{space}"
      end

      def deploy
        shell "./cf push #{args}".strip, assert: 'Failed to push app'
      end

      def finish
        shell "./cf logout"
        super
      end

      def args
        args = []
        args << quote(app_name)  if app_name?
        args << "-f #{manifest}" if manifest?
        args.join(' ')
      end
    end
  end
end
