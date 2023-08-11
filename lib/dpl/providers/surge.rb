# frozen_string_literal: true

require 'open-uri'

module Dpl
  module Providers
    class Surge < Provider
      register :surge

      status :stable

      description sq(<<-STR)
        tbd
      STR

      node_js '>= 8.8.1'

      gem 'json'
      npm :surge
      env :surge

      opt '--login EMAIL', 'Surge login (the email address you use with Surge)', required: true
      opt '--token TOKEN', 'Surge login token (can be retrieved with `surge token`)', required: true, secret: true
      opt '--domain NAME', 'Domain to publish to. Not required if the domain is set in the CNAME file in the project folder.'
      opt '--project PATH', 'Path to project directory relative to repo root', default: '.'

      cmds deploy: 'surge %{project} %{domain}'

      msgs invalid_project: '%{project} is not a directory',
           missing_domain: 'Please set the domain in .travis.yml or in a CNAME file in the project directory'

      def login
        ENV['SURGE_LOGIN'] ||= opts[:login]
        ENV['SURGE_TOKEN'] ||= opts[:token]
      end

      def validate
        error :invalid_project if invalid_project?
        error :missing_domain  if missing_domain?
      end

      def deploy
        shell :deploy
      end

      def invalid_project?
        !File.directory?(project)
      end

      def missing_domain?
        !domain && !File.exist?("#{project}/CNAME")
      end

      def project
        expand(super, build_dir)
      end
    end
  end
end
