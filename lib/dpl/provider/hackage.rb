module DPL
  class Provider
    class Hackage < Provider

      def check_auth
      end

      def check_app
        context.shell "cabal check"
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "cabal sdist"
        Dir.glob("dist/*.tar.gz") do |tar|
          context.shell "cabal upload --username=#{option(:username)} --password=#{option(:password)} #{tar}"
        end
      end
    end
  end
end

