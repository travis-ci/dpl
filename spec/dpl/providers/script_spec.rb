describe Dpl::Providers::Script do
  let(:args) { |e| args_from_description(e) }

  before { subject.run }

  describe 'given --script ./one --script ./two' do
    it { should have_run './one' }
    it { should have_run './two' }
  end
end
