describe Dpl::Providers::Script do
  let(:args) { |e| args_from_description(e) }

  before { subject.run }

  describe 'given --script ./script' do
    it { should have_run './script' }
  end
end

