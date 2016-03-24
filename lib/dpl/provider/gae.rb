module DPL
  class Provider
    class GAE < Provider
      experimental 'Google App Engine'

      BASE='https://dl.google.com/dl/cloudsdk/channels/rapid/'
      NAME='google-cloud-sdk'
      EXT='.tar.gz'
      INSTALL='~'
      BOOTSTRAP="#{INSTALL}/#{NAME}/bin/bootstrapping/install.py"
      GCLOUD="#{INSTALL}/#{NAME}/bin/gcloud"

      def install_deploy_dependencies
        if File.exists? GCLOUD
          return
        end

        $stderr.puts 'Downloading Google Cloud SDK ...'

        unless context.shell("curl -L #{BASE + NAME + EXT} | gzip -d | tar -x -C #{INSTALL}")
          error 'Could not download Google Cloud SDK.'
        end

        $stderr.puts 'Bootstrapping Google Cloud SDK ...'

        unless context.shell("#{BOOTSTRAP} --usage-reporting=false --command-completion=false --path-update=false")
          error 'Could not bootstrap Google Cloud SDK.'
        end
      end

      def needs_key?
        false
      end

      def check_auth
        unless context.shell("#{GCLOUD} -q --verbosity debug auth activate-service-account --key-file #{keyfile}")
          error 'Authentication failed.'
        end
      end

      def keyfile
        options[:keyfile] || context.env['GOOGLECLOUDKEYFILE'] || 'service-account.json'
      end

      def project
        options[:project] || context.env['GOOGLECLOUDPROJECT'] || context.env['CLOUDSDK_CORE_PROJECT'] || File.dirname(context.env['TRAVIS_REPO_SLUG'] || '')
      end

      def version
        options[:version] || ''
      end

      def config
        options[:config] || 'app.yaml'
      end

      def no_promote
        options[:no_promote]
      end

      def use_cloud_build
        options[:use_cloud_build] || 'false'
      end

      def verbosity
        options[:verbosity] || 'warning'
      end

      def docker_build
        options[:docker_build] || 'remote'
      end

      def no_stop_previous_version
        options[:no_stop_previous_version]
      end

      def push_app
        context.shell "#{GCLOUD} config set app/use_cloud_build #{use_cloud_build}"
        command = GCLOUD
        command << ' --quiet'
        command << " --verbosity \"#{verbosity}\""
        command << " --project \"#{project}\""
        command << " preview app deploy \"#{config}\""
        command << " --version \"#{version}\""
        command << " --docker-build \"#{docker_build}\""
        command << " --#{no_promote ? 'no-' : ''}promote"
        command << (no_stop_previous_version ? ' --no-stop-previous-version' : '')
        unless context.shell(command)
          log 'Deployment failed.'
          context.shell('find $HOME/.config/gcloud/logs -type f -print -exec cat {} \;')
          error ''
        end
      end
    end
  end
end
