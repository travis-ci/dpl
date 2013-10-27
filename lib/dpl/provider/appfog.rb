module DPL
  class Provider
    class Appfog < Provider
      requires 'af', :load => 'vmc'

      def check_auth
        context.shell "af login --email=#{option(:email)} --password=#{option(:password)}"
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "af update #{options[:app] || File.basename(Dir.getwd)}"
        context.shell "af logout"
      end
    end
  end
end
