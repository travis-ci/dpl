describe Dpl::Providers::Npm do
  let(:args) { |e| %w(--email email --api_key key) + args_from_description(e) }

  let(:npmrc) do
    sq(<<-rc)
      _auth = \${NPM_API_KEY}
      email = email
    rc
  end

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[info] NPM version: 1' }
    it { should have_run '[info] Authenticated with email email and API key ********************' }
    it { should have_run '[info] ~/.npmrc size: 36' }
    it { should have_run 'env NPM_API_KEY=key npm publish' }
    it { should have_run_in_order }
    it { should have_written '~/.npmrc', npmrc }
  end

  describe 'given --tag tag' do
    it { should have_run 'env NPM_API_KEY=key npm publish --tag="tag"' }
  end
end
