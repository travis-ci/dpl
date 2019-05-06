module Support
  module Matchers
    module Shared
      attr_reader :cmd

      def match?(other)
        str.is_a?(Regexp) ? str.match(other) : str == other
      end

      def cmds
        cmd.ctx.cmds
      end

      def indent(str)
        str.lines[0] + str.lines[1..-1].map { |str| "#{' ' * 2}#{str}" }.join
      end
    end

    class HaveRun < Struct.new(:str)
      include Shared

      def matches?(cmd)
        @cmd = cmd
        cmd.ctx.cmds.any? { |cmd| match?(cmd) }
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

    class HaveDeprecated < Struct.new(:opt)
      include Shared

      def matches?(cmd)
        @cmd = cmd
        cmd.ctx.cmds.any? { |cmd| cmd =~ /deprecated option.*#{opt},/ }
      end

      def description
        "have deprecated #{opt.inspect}"
      end

      def failure_message
        "Expected the command\n\n  #{opt}\n\nto be deprecated. Instead, we have run the commands:\n\n  #{indent(cmds.join("\n"))}"
      end

      def failure_message_when_negated
        "Expected the command\n\n  #{opt}\n\nto not be deprecated, but it is:\n\n  #{indent(cmds.join("\n"))}"
      end
    end

    def have_run(str)
      HaveRun.new(str)
    end

    def have_deprecated(str)
      HaveDeprecated.new(str)
    end
  end
end
