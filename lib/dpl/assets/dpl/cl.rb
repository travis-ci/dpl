# Stub Cl implementation so the Gemfile can require dpl

class Cl
  class Ctx; end

  class Cmd
    class << self
      def abstract(*); end
      def arg(*); end
      def opt(*); end
      def required(*); end
      def description(*); end
      def summary(*); end
    end
  end
end
