module Support
  module Require
    def self.included(base)
      base.before do
        described_class.require(ctx) if described_class.respond_to?(:require)
      end
    end
  end
end

