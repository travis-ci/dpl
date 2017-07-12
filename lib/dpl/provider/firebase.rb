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
        command = "firebase deploy --non-interactive"
        command << " --project #{options[:project]}" if options[:project]
        command << " --message '#{options[:message]}'" if options[:message]
        command << " --token '#{options[:token]}'" if options[:token]
        context.shell command
      end
    end
  end
end
