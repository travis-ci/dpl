describe Dpl::Providers::Npm, fakefs: true do
  let(:args) { |e| %w(--email email --api_key key) + args_from_description(e) }

  dir File.expand_path('~')

  before { subject.run }

  describe 'by default' do
    it { should have_run '[info] NPM version: 1' }
    it { should have_run '[info] Authenticated with email email and API key ********************' }
    it { should have_run '[info] ~/.npmrc size: 36' }
    it { should have_run 'env NPM_API_KEY=key npm publish' }
    it { should have_run_in_order }
  end

  describe 'given --tag tag' do
    it { should have_run 'env NPM_API_KEY=key npm publish --tag="tag"' }
  end
end
