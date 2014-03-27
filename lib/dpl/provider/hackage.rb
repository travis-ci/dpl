module DPL
  class Provider
    class Hackage < Provider
      apt_get 'cabal', 'cabal-install'

      def check_auth
        unless option(:username) and option(:password)
          raise Error, "must supply username and password"
        end
      end

      def check_app
        context.shell "cabal check" or raise Error, "cabal check failed"
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "cabal sdist" or raise Error, "cabal sdist failed"
        Dir.glob("dist/*.tar.gz") do |tar|
          context.shell "cabal upload --username=#{option(:username)} --password=#{option(:password)} #{tar}"
        end
      end
    end
  end
end

