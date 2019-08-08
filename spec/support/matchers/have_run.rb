module Support
  module Matchers
    module RecordCmds
      def self.included(base)
        base.before(:context) { @expected_cmds = [] }
      end
    end

    class HaveRun < Struct.new(:cmds, :str)
      include Shared

      def matches?(cmd)
        cmds << str if cmds
        @cmd = cmd
        cmd.ctx.cmds.any? { |cmd, opts| match?(cmd) }
      end

      def description
        "run #{str.inspect}"
      end

      def failure_message
        "Expected the command\n\n  #{str}\n\nto have run, but it didn't. Instead, we have run the commands:\n\n  #{indent(cmd.ctx.cmds.join("\n"))}"
      end

      def failure_message_when_negated
        "Expected the command\n\n  #{str}\n\nto not have run, but it did:\n\n  #{indent(cmd.ctx.cmds.join("\n"))}"
      end
    end

    # needs record: true on the context
    class HaveRunInOrder < Struct.new(:expected, :example)
      include Shared

      attr_reader :actual

      def matches?(cmd)
        @actual = cmd.ctx.cmds.map { |str| expected.detect { |cmd| match?(str, cmd) } }.compact.uniq
        expected == actual
      end

      def description
        'have run commands in order'
      end

      def failure_message
        "Expected the commands\n\n#{indent(expected.join("\n"))}\n\nto have run in this order, but they have run as follows:\n\n#{indent(actual.join("\n"))}"
      end

      def indent(strs)
        strs.lines.map { |line| "  #{line}" }.join
      end
    end

    def have_run(str)
      HaveRun.new(@expected_cmds, str)
    end

    def have_run_in_order
      # p example_group
      HaveRunInOrder.new(@expected_cmds)
    end
  end
end
