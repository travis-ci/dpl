module Dpl
  module Providers
    class Cloudfoundry < Provider
      full_name 'Cloud Foundry'

      description sq(<<-str)
        tbd
      str

      opt '--username USER',       'Cloud Foundry username', required: true
      opt '--password PASS',       'Cloud Foundry password', required: true
      opt '--organization ORG',    'Cloud Foundry target organization', required: true
      opt '--space SPACE',         'Cloud Foundry target space', required: true
      opt '--api URL',             'Cloud Foundry api URL', required: true
      opt '--app_name APP',        'Application name'
      opt '--buildpack PACK',      'Custom buildpack name or Git URL'
      opt '--manifest FILE',       'Path to the manifest'
      opt '--skip_ssl_validation', 'Skip SSL validation'
      opt '--logout', default: true, internal: true

      cmds install: 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz',
           api:     './cf api %{api} %{skip_ssl_validation_opt}',
           login:   './cf login -u "%{username}" -p "%{password}" -o "%{organization}" -s "%{space}"',
           push:    './cf push %{push_args}',
           logout:  './cf logout'

      msgs login:   '$ ./cf login -u "%{username}" -p "%{obfuscated_password}" -o "%{organization}" -s "%{space}"'

      errs push: 'Failed to push app'

      msgs manifest_missing: 'Application must have a manifest.yml for unattended deployment'

      def install
        shell :install
      end

      def validate
        error :manifest_missing if manifest? && manifest_missing?
      end

      def login
        shell :api
        info  :login
        shell :login
      end

      def deploy
        shell :push, assert: true
      end

      def finish
        shell :logout if logout?
      end

      private

        def push_args
          args = []
          args << quote(app_name)  if app_name?
          args << "-f #{manifest}" if manifest?
          args.join(' ')
        end

        def skip_ssl_validation_opt
          '--skip-ssl-validation' if skip_ssl_validation?
        end

        def manifest_missing?
          !File.exists?(manifest)
        end
    end
  end
end
