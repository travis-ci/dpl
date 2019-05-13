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


      URL = 'https://%s:%s@%s.scm.azurewebsites.net:443/%s.git'

      CMDS = {
        git_push:     'git push --force --quiet %{url} HEAD:refs/heads/master',
        git_checkout: 'git checkout HEAD',
        git_add:      'git add . --all --force',
        git_commit:   'git commit -m "Skip cleanup commit"',
      }

      MSGS = {
        commit: 'Skipping cleanup, committing any changes',
        deploy: 'Deploying to Azure Web App: %{app}'
      }

      def setup
        commit if skip_cleanup?
      end

      def deploy
        info :deploy
        shell :git_push, silence: !verbose?
      end

      private

        def url
          URL % [username, password, target, site]
        end

        def target
          slot || site
        end

        def commit
          info :commit
          shell :git_checkout
          shell :git_add
          shell :git_commit
        end
    end
  end
end
