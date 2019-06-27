module Dpl
  module Providers
    class Gae < Provider
      full_name 'Google App Engine'

      description sq(<<-str)
        tbd
      str

      python '~> 2.7.9'

      env :googlecloud, :cloudsdk_core

      opt '--project ID', 'Project ID used to identify the project on Google Cloud', required: true
      opt '--keyfile FILE', 'Path to the JSON file containing your Service Account credentials in JSON Web Token format. To be obtained via the Google Developers Console. Should be handled with care as it contains authorization keys.', default: 'service-account.json'
      opt '--config FILE', 'Path to your service configuration file', default: 'app.yaml'
      opt '--version VER', 'The version of the app that will be created or replaced by this deployment. If you do not specify a version, one will be generated for you'
      opt '--verbosity LEVEL', 'Adjust the log verbosity', default: 'warning'
      opt '--no_promote', 'Do not promote the deployed version'
      opt '--no_stop_previous_version', 'Prevent your deployment from stopping the previously promoted version. This is from the future, so might not work (yet).'
      opt '--install_sdk', 'Do not install the Google Cloud SDK', default: true

      cmds install:   'curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | gzip -d | tar -x -C ~',
           bootstrap: '~/google-cloud-sdk/bin/bootstrapping/install.py --usage-reporting=false --command-completion=false --path-update=false',
           login:     'gcloud -q auth activate-service-account --key-file %{keyfile}',
           deploy:    'gcloud -q app deploy %{config} %{deploy_opts}',
           cat_logs:  'find $HOME/.config/gcloud/logs -type f -print -exec cat {} \;'

      errs install:   'Failed to download Google Cloud SDK.',
           login:     'Failed to authenticate.',
           bootstrap: 'Failed bootstrap Google Cloud SDK.'

      msgs failed:    'Deployment failed.'

      path '~/google-cloud-sdk/bin'

      def install
        return unless install_sdk?
        # return if which 'gcloud'
        # shell 'sudo apt-get remove google-cloud-sdk' if which 'gcloud'
        shell :install, echo: true, assert: true
        shell :bootstrap, echo: true, assert: true
      end

      def login
        shell :login, echo: true, assert: true
      end

      def deploy
        shell :deploy, echo: true
        failed unless success?
      end

      private

        def deploy_opts
          opts = [*opts_for(%i(project verbosity version))]
          opts << '--no-promote' if no_promote?
          opts << '--no-stop-previous-version' if no_stop_previous_version?
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
