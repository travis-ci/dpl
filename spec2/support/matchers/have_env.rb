module Support
  module Matchers
    class HaveEnv < Struct.new(:env)
      include Shared

      def matches?(*)
        env.all? { |key, value| ENV[key.to_s] == value }
      end

      def description
        "run #{str.inspect}"
      end

      def failure_message
        "Expected ENV to include\n\n  #{env.inspect}\n\nbut it does not."
      end

      def failure_message_when_negated
        "Expected ENV to not include\n\n  #{env.inspect}\n\nbut it does."
      end
    end

    def have_env(str)
      HaveEnv.new(str)
    end
  end
end
