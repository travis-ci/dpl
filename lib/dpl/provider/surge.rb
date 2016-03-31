module DPL
  class Provider
    class Surge < Provider
      npm_g 'surge'

      def project
        File.expand_path("./" + (options[:project] || '') )
      end

      def domain
        options[:domain] || ''
      end

      def check_auth
		raise Error, "Please add SURGE_TOKEN in Travis settings (get your token with 'surge token')" unless context.env['SURGE_TOKEN']
        raise Error, "Please add SURGE_LOGIN in Travis settings (its your email)" unless context.env['SURGE_LOGIN']
      end

      def check_app
      	raise Error, "Please set a valid project folder path in .travis.yml under deploy: project: myPath" unless File.directory?(project)
      	raise Error, "Please set domain as .travis.yml under deploy: project: myDomain (or in a CNAME file in the repo project folder)" unless ''!=domain || File.exist?("#{project}/CNAME")
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "surge #{project} #{domain}"
      end
    end
  end
end
