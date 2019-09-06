describe Dpl::Providers::Cargo do
  before { |c| subject.run if run?(c) }

  describe 'given --token 1234' do
    it { should have_run '[info] $ cargo publish --token 1*******************' }
    it { should have_run 'cargo publish --token 1234' }
  end
end
