# frozen_string_literal: true

module Dpl
  module Providers
    class Gae < Provider
      register :gae

      status :stable

      full_name 'Google App Engine'

      description sq(<<-STR)
        tbd
      STR

      python '>= 2.7.9'

      env :gae, :googlecloud, :cloudsdk_core, allow_skip_underscore: true

      opt '--project ID', 'Project ID used to identify the project on Google Cloud', required: true
      opt '--keyfile FILE', 'Path to the JSON file containing your Service Account credentials in JSON Web Token format. To be obtained via the Google Developers Console. Should be handled with care as it contains authorization keys.', default: 'service-account.json'
      opt '--config FILE', 'Path to your service configuration file', type: :array, default: 'app.yaml'
      opt '--version VER', 'The version of the app that will be created or replaced by this deployment. If you do not specify a version, one will be generated for you'
      opt '--verbosity LEVEL', 'Adjust the log verbosity', default: 'warning'
      opt '--promote', 'Whether to promote the deployed version', default: true
      opt '--stop_previous_version', 'Prevent the deployment from stopping a previously promoted version', default: true
      opt '--install_sdk', 'Whether to install the Google Cloud SDK', default: true

      URL = 'https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz'

      cmds install: 'curl -L %{URL} | tar xz -C ~ && ~/google-cloud-sdk/install.sh --path-update false --usage-reporting false --command-completion false',
           login: 'gcloud -q auth activate-service-account --key-file %{keyfile}',
           deploy: 'gcloud -q app deploy %{config} %{deploy_opts}',
           cat_logs: 'find $HOME/.config/gcloud/logs -type f -print -exec cat {} \;'

      errs install: 'Failed to download Google Cloud SDK.',
           login: 'Failed to authenticate.'

      msgs failed: 'Deployment failed.'

      path '~/google-cloud-sdk/bin'

      def install
        return unless install_sdk?

        shell :install
      end

      def login
        shell :login
      end

      def deploy
        shell :deploy
        failed unless success?
      end

      private

      def deploy_opts
        opts = [*opts_for(%i[project verbosity version])]
        opts << '--no-promote' unless promote?
        opts << '--no-stop-previous-version' unless stop_previous_version?
        opts.join(' ')
      end

      def failed
        warn :failed
        shell :cat_logs
        error ''
      end

      def project
        super || File.dirname(build_dir)
      end
    end
  end
end
