module Support
  module Matchers
    class HaveRun < Struct.new(:str)
      include Shared

      def matches?(cmd)
        @cmd = cmd
        cmd.ctx.cmds.any? { |cmd, opts| match?(cmd) }
      end

      def description
        "run #{str.inspect}"
      end

      def failure_message
        "Expected the command\n\n  #{str}\n\nto have run, but it didn't. Instead, we have run the commands:\n\n  #{indent(cmds.join("\n"))}"
      end

      def failure_message_when_negated
        "Expected the command\n\n  #{str}\n\nto not have run, but it did:\n\n  #{indent(cmds.join("\n"))}"
      end
    end

    def have_run(str)
      HaveRun.new(str)
    end
  end
end
