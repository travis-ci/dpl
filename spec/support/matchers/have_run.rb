module Support
  module Matchers
    class HaveRun < Struct.new(:str)
      include Shared

      def self.cmds
        @cmds ||= []
      end

      def matches?(cmd)
        self.class.cmds << str
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

    class HaveRunInOrder
      include Shared

      def matches?(cmd)
        @expected = HaveRun.cmds.clear
        @actual = cmd.ctx.cmds.map { |str| @expected.map { |cmd| cmd if match?(str, cmd) } }.flatten.compact
        @expected == @actual
      end

      def description
        'have run commands in order'
      end
    end

    def have_run(str)
      HaveRun.new(str)
    end

    def have_run_in_order
      HaveRunInOrder.new
    end
  end
end
