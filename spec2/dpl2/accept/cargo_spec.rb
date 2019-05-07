describe Dpl::Providers::Cargo, 'acceptance' do
  before { subject.run }

  describe 'given --token token' do
    it { should have_run 'cargo publish --token token' }
  end
end
