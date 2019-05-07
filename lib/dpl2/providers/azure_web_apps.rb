module Dpl
  module Providers
    class AzureWebApps < Provider
      summary 'Anynines deployment provider'

      description <<~str
        tbd
      str

      env :AZURE_WA

      opt '--site SITE',     'Web App name (e.g. myapp in myapp.azurewebsites.net)', required: true
      opt '--username NAME', 'Web App Deployment Username', required: true
      opt '--password PASS', 'Web App Deployment Password', required: true
      opt '--slot SLOT',     'Slot name (if your app uses staging deployment)'
      opt '--verbose',       'Print deployment output from Azure. Warning: If authentication fails, Git prints credentials in clear text. Correct credentials remain hidden.'

      CMD = 'git push --force --quiet %s HEAD:refs/heads/master'
      URL = 'https://%s:%s@%s.scm.azurewebsites.net:443/%s.git'

      # fold deploy: 'Deploying to Azure Web App: %s'

      def setup
        skip_cleanup if skip_cleanup?
      end

      def deploy
        shell cmd, silence: !verbose?
      end

      def cmd
        CMD % url
      end

      def url
        URL % [username, password, target, site]
      end

      def target
        slot || site
      end

      def skip_cleanup
        info 'Skipping Cleanup'
        shell 'git checkout HEAD'
        shell 'git add . --all --force'
        shell 'git commit -m "Skip Cleanup Commit"'
      end
    end
  end
end
