# frozen_string_literal: true

module Dpl
  module Providers
    class AzureWebApps < Provider
      register :azure_web_apps

      status :alpha

      full_name 'Azure Web Apps'

      description sq(<<-STR)
        tbd
      STR

      env :AZURE_WA

      opt '--username NAME', 'Web App Deployment Username', required: true
      opt '--password PASS', 'Web App Deployment Password', required: true, secret: true
      opt '--site SITE',     'Web App name (e.g. myapp in myapp.azurewebsites.net)', required: true
      opt '--slot SLOT',     'Slot name (if your app uses staging deployment)'
      opt '--verbose',       'Print deployment output from Azure. Warning: If authentication fails, Git prints credentials in clear text. Correct credentials remain hidden.'

      needs :git

      cmds checkout: 'git checkout HEAD',
           add: 'git add . --all --force',
           commit: 'git commit -m "Cleanup commit"',
           deploy: 'git push --force --quiet %{url} HEAD:refs/heads/master'

      msgs commit: 'Committing changes to git',
           deploy: 'Deploying to Azure Web App: %{site}'

      errs push: 'Failed pushing to Azure Web Apps'

      URL = 'https://%s:%s@%s.scm.azurewebsites.net:443/%s.git'

      def setup
        commit if git_dirty? && !cleanup?
      end

      def deploy
        shell :deploy, silence: !verbose?
      end

      private

      def url
        format(URL, username, password, target, site)
      end

      def target
        slot || site
      end

      def commit
        shell :checkout
        shell :add
        shell :commit
      end
    end
  end
end
