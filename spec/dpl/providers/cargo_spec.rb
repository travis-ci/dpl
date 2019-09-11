describe Dpl::Providers::Cargo do
  let(:args) { |e| %w(--token 1234) + args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_run '[info] $ cargo publish --token="1*******************"' }
    it { should have_run 'cargo publish --token="1234"' }
  end

  describe 'given --allow_dirty' do
    it { should have_run '[info] $ cargo publish --token="1*******************" --allow-dirty' }
    it { should have_run 'cargo publish --token="1234" --allow-dirty' }
  end

  describe 'with credentials in env vars', run: false do
    env CARGO_TOKEN: '1234'
    it { expect { subject.run }.to_not raise_error }
  end
end
