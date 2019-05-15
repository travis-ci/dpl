module Support
  module Require
    def self.included(base)
      base.before do
        const = base.described_class
        Dpl::Require.new(ctx, const).run if const.respond_to?(:requires)
      end
    end
  end
end

