# frozen_string_literal: true

module Dpl
  module Providers
    class Openshift < Provider
      register :openshift

      status :stable

      full_name 'OpenShift'

      description sq(<<-STR)
        tbd
      STR

      env :openshift

      opt '--server SERVER',   'OpenShift server', required: true
      opt '--token TOKEN',     'OpenShift token', required: true, secret: true
      opt '--project PROJECT', 'OpenShift project', required: true
      opt '--app APP',         'OpenShift application', default: :repo_name

      cmds install: 'curl %{URL} | tar xz',
           login: './oc login --token=%{token} --server=%{server}',
           prepare: './oc project %{project}',
           deploy: './oc start-build %{app} --follow --commit %{git_sha}'

      errs install: 'CLI tool installation failed',
           login: 'Authentication failed',
           prepare: 'Unable to select project %{project}',
           deploy: 'Deployment failed'

      URL = 'https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.1/linux/oc.tar.gz'

      def install
        shell :install
      end

      def login
        shell :login
      end

      def prepare
        shell :prepare
      end

      def deploy
        shell :deploy
      end
    end
  end
end
