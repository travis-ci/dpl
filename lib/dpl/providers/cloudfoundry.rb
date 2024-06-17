# frozen_string_literal: true

module Dpl
  module Providers
    class Cloudfoundry < Provider
      register :cloudfoundry

      status :stable

      full_name 'Cloud Foundry'

      description sq(<<-STR)
        tbd
      STR

      env :cloudfoundry

      opt '--username USER',       'Cloud Foundry username', required: true
      opt '--password PASS',       'Cloud Foundry password', required: true, secret: true
      opt '--organization ORG',    'Cloud Foundry organization', required: true
      opt '--space SPACE',         'Cloud Foundry space', required: true
      opt '--api URL',             'Cloud Foundry api URL', default: 'https://api.run.pivotal.io'
      opt '--app_name APP',        'Application name'
      opt '--buildpack PACK',      'Buildpack name or Git URL'
      opt '--manifest FILE',       'Path to the manifest'
      opt '--skip_ssl_validation', 'Skip SSL validation'
      opt '--deployment_strategy STRATEGY', 'Deployment strategy, either rolling or null'
      opt '--v3', 'Use the v3 API version to push the application'
      opt '--logout', default: true, internal: true

      cmds install: 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&version=v7&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz',
           api: './cf api %{api} %{skip_ssl_validation_opt}',
           login: './cf login -u %{username} -p %{password} -o %{organization} -s %{space}',
           push: './cf %{push_cmd} %{push_args}',
           logout: './cf logout'

      errs install: 'Failed to install CLI tools',
           api: 'Failed to set api %{api}',
           login: 'Failed to login',
           push: 'Failed to push app',
           logout: 'Failed to logout'

      msgs manifest_missing: 'Application must have a manifest.yml for unattended deployment'

      def install
        shell :install
      end

      def validate
        error :manifest_missing if manifest? && manifest_missing?
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

      def push_cmd
        v3? ? 'v3-push' : 'push'
      end

      def push_args
        args = []
        args << quote(app_name)  if app_name?
        args << "-f #{manifest}" if manifest?
        args << "--strategy #{deployment_strategy}" if deployment_strategy?
        args.join(' ')
      end

      def skip_ssl_validation_opt
        '--skip-ssl-validation' if skip_ssl_validation?
      end

      def manifest_missing?
        !File.exist?(manifest)
      end
    end
  end
end
