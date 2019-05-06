require 'cl'

module Dpl
  module Ctx
    class Test < Cl::Ctx
      def initialize
        super('dpl')
      end

      def fold(name)
        cmds << "[fold] #{name}"
        yield.tap { cmds << "[unfold] #{name}" }
      end

      def shell(cmd)
        cmds << cmd
      end

      def warn(msg)
        cmds << "[warn] #{msg}"
      end

      def deprecate_opt(old, new)
        warn("deprecated option #{old}, please use: #{new}")
      end

      def cmds
        @cmds ||= []
      end
    end
  end
end
