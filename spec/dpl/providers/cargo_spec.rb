describe Dpl::Providers::Cargo do
  before { |c| subject.run if run?(c) }

  describe 'given --token 1234' do
    it { should have_run '[info] $ cargo publish --token="1*******************"' }
    it { should have_run 'cargo publish --token="1234"' }
  end

  describe 'given --token 1234 --allow_dirty' do
    it { should have_run '[info] $ cargo publish --token="1*******************" --allow-dirty' }
    it { should have_run 'cargo publish --token="1234" --allow-dirty' }
  end

  describe 'with credentials in env vars', run: false do
    env CARGO_TOKEN: '1234'
    it { expect { subject.run }.to_not raise_error }
  end
end
