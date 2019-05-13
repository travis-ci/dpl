module Support
  module Ctx
    def self.included(base)
      base.let(:ctx) { Dpl::Ctx::Test.new }
    end
  end
end
