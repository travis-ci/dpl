module Dpl
  module Providers
    class AzureWebApps < Provider
      status :dev

      full_name 'Azure Web Apps'

      description sq(<<-str)
        tbd
      str

      env :AZURE_WA

      opt '--site SITE',     'Web App name (e.g. myapp in myapp.azurewebsites.net)', required: true
      opt '--username NAME', 'Web App Deployment Username', required: true
      opt '--password PASS', 'Web App Deployment Password', required: true, secret: true
      opt '--slot SLOT',     'Slot name (if your app uses staging deployment)'
      opt '--verbose',       'Print deployment output from Azure. Warning: If authentication fails, Git prints credentials in clear text. Correct credentials remain hidden.'

      needs :git

      cmds push:     'git push --force --quiet %{url} HEAD:refs/heads/master',
           checkout: 'git checkout HEAD',
           add:      'git add . --all --force',
           commit:   'git commit -m "Cleanup commit"'

      msgs commit:   'Skipping cleanup, committing changes to git',
           deploy:   'Deploying to Azure Web App: %{site}'

      errs push:     'Failed pushing to Azure Web Apps'

      URL = 'https://%s:%s@%s.scm.azurewebsites.net:443/%s.git'

      def setup
        commit if git_dirty? && !cleanup?
      end

      def deploy
        info :deploy
        shell :push, silence: !verbose?
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
          shell :checkout
          shell :add
          shell :commit
        end
    end
  end
end
