require 'support/matchers/shared'

module Support
  module Matchers
    class HaveDeprecated < Struct.new(:opt)
      include Shared

      def matches?(cmd)
        @cmd = cmd
        cmd.ctx.cmds.any? { |cmd| cmd =~ /Deprecated option.*#{opt} / }
      end

      def description
        "have deprecated #{opt.inspect}"
      end

      def failure_message
        "Expected the command\n\n  #{opt}\n\nto be deprecated. Instead, we have run the commands:\n\n  #{indent(cmd.ctx.cmds.join("\n"))}"
      end

      def failure_message_when_negated
        "Expected the command\n\n  #{opt}\n\nto not be deprecated, but it is:\n\n  #{indent(cmd.ctx.cmds.join("\n"))}"
      end
    end

    def have_deprecated(str)
      HaveDeprecated.new(str)
    end
  end
end
