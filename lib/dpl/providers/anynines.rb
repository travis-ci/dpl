# frozen_string_literal: true

module Dpl
  module Providers
    class Anynines < Provider
      register :anynines

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      env :anynines

      opt '--username USER',    'anynines username', required: true
      opt '--password PASS',    'anynines password', required: true, secret: true
      opt '--organization ORG', 'anynines organization', required: true
      opt '--space SPACE',      'anynines space', required: true
      opt '--app_name APP',     'Application name'
      opt '--buildpack PACK',   'Buildpack name or Git URL'
      opt '--manifest FILE',    'Path to the manifest'
      opt '--logout', default: true, internal: true

      API = 'https://api.de.a9s.eu'

      cmds install: 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz',
           api: './cf api %{url}',
           login: './cf login -u %{username} -p %{password} -o %{organization} -s %{space}',
           push: './cf push %{args}',
           logout: './cf logout'

      errs install: 'Failed to install CLI tools',
           api: 'Failed to set api',
           login: 'Failed to login',
           target: 'Failed to target organization %{organization}, space %{space}',
           push: 'Failed to push app',
           logout: 'Failed to logout'

      def install
        shell :install
      end

      def login
        shell :api
        shell :login
      end

      def deploy
        shell :push
      end

      def finish
        shell :logout if logout?
      end

      private

      def url
        API
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
