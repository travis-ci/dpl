module DPL
  class Provider
    class APM < Provider
      experimental "Atom Package Manager"

      def needs_key?
        false
      end

      def travis_tag
        # Check if $TRAVIS_TAG is unset or set but empty
        if context.env.fetch('TRAVIS_TAG','') == ''
          nil
        else
          context.env['TRAVIS_TAG']
        end
      end

      def get_tag
        if travis_tag.nil?
          @tag ||= `git describe --tags --exact-match 2>/dev/null`.chomp
        else
          @tag ||= travis_tag
        end
      end

      def check_auth
      end

      def push_app
        context.shell "env ATOM_ACCESS_TOKEN=#{option(:api_key)} #{context.env['APM_SCRIPT_PATH']} publish --tag #{get_tag}"
      end
    end
  end
end
