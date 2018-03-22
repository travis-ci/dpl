module DPL
  class Provider
    class Firebase < Provider
      npm_g 'firebase-tools@^3.0', 'firebase'

      def check_auth
        raise Error, "must supply token option or FIREBASE_TOKEN environment variable" if !options[:token] && !context.env['FIREBASE_TOKEN']
      end

      def check_app
        error "missing firebase.json" unless File.exist? "firebase.json"
      end

      def needs_key?
        false
      end

      def push_app
        Dir.chdir(local_dir) do
          command = "firebase deploy --non-interactive"
          command << " --project #{options[:project]}" if options[:project]
          command << " --message '#{options[:message]}'" if options[:message]
          command << " --token '#{options[:token]}'" if options[:token]
          context.shell command
        end
      end

      def local_dir
        options[:local_dir] || Dir.pwd
      end
    end
  end
end
