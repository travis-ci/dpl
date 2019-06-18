module Dpl
  module Providers
    class Surge < Provider
      description sq(<<-str)
        tbd
      str

      npm :surge
      env :surge

      opt '--login EMAIL', 'Surge login (the email address you use with Surge)', required: true
      opt '--token TOKEN', 'Surge login token (can be retrieved with `surge token`)', required: true
      opt '--domain NAME', 'Domain to publish to. Not required if the domain is set in the CNAME file in the project folder.'
      opt '--project PATH', 'Path to project directory relative to repo root', default: '.'

      cmds deploy: 'surge %{project} %{domain}'

      msgs invalid_project: '%{project} is not a directory',
           missing_domain:  'Please set the domain in .travis.yml or in a CNAME file in the project directory'

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
        File.expand_path(super, build_dir)
      end
    end
  end
end
