# frozen_string_literal: true

describe Dpl::Providers::Script do
  let(:args) { |e| args_from_description(e) }

  before { subject.run }

  describe 'given --script ./script' do
    it { is_expected.to have_run './script' }
  end
end

