describe Dpl::Providers::Npm do
  let(:args) { |e| %w(--email email --api_key 12345) + args_from_description(e) }

  let(:npmrc) do
    sq(<<-rc)
      _auth = 12345
      email = email
    rc
  end

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run '[info] npm version: 1' }
    it { should have_run '[info] Authenticated with API token 1*******************' }
    it { should have_run '[info] ~/.npmrc size: 27' }
    it { should have_run 'npm config set registry "registry.npmjs.org"' }
    it { should have_run 'npm publish .' }
    it { should have_run_in_order }
    it { should have_written '~/.npmrc', npmrc }
  end

  describe 'given --registry registry' do
    it { should have_run 'npm config set registry "registry"' }
  end

  describe 'given --src ./dir' do
    it { should have_run 'npm publish ./dir' }
  end

  describe 'given --access public' do
    it { should have_run 'npm publish . --access="public"' }
  end

  describe 'given --tag tag' do
    it { should have_run 'npm publish . --tag="tag"' }
  end
end
