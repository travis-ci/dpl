module DPL
  class Provider
    class Appfog < Provider
      requires 'json_pure', :version => '< 1.7', :load => 'json/pure'
      requires 'af', :version => '< 0.3.20', :load => 'vmc'

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
