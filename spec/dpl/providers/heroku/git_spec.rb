describe Dpl::Providers::Heroku do
  let(:args) { |e| %w(--strategy git) + creds + args_from_description(e) }
  let(:user) { JSON.dump(email: 'email') }
  let(:dyno) { JSON.dump(attach_url: 'attach_url') }
  let(:pass) { 'key' }

  let(:netrc) do
    sq(<<-rc)
      machine git.heroku.com
        login email
        password #{pass}
    rc
  end

  before { stub_request(:get, 'https://api.heroku.com/account').and_return(body: user) }
  before { stub_request(:get, 'https://api.heroku.com/apps/dpl') }
  before { stub_request(:get, 'https://api.heroku.com/apps/other') }
  before { stub_request(:post, 'https://api.heroku.com/apps/dpl/dynos').and_return(body: dyno) }
  before { stub_request(:delete, 'https://api.heroku.com/apps/dpl/dynos') }
  before { allow(Rendezvous).to receive(:start) }
  before { |c| subject.run if run?(c) }

  describe 'using --api_key' do
    let(:creds) { %w(--api_key key) }

    describe 'by default', record: true do
      it { should have_run '[print] Authenticating ... ' }
      it { should have_run '[print] Checking for app dpl ... ' }
      it { should have_run 'git fetch origin $TRAVIS_BRANCH --unshallow' }
      it { should have_run 'git push https://git.heroku.com/dpl.git HEAD:refs/heads/master -f' }
      it { should have_requested :get, 'https://api.heroku.com/account' }
      it { should have_requested :get, 'https://api.heroku.com/apps/dpl' }
      it { should have_run_in_order }
      it { should have_written '~/.netrc', netrc }
    end

    describe 'given --app other' do
      it { should have_run '[print] Checking for app other ... ' }
      it { should have_run 'git push https://git.heroku.com/other.git HEAD:refs/heads/master -f' }
      it { should have_requested :get, 'https://api.heroku.com/apps/other' }
    end

    describe 'given --log_level debug' do
      it { should have_logged 'get https://api.heroku.com/account' }
      it { should have_logged 'Accept: "application/vnd.heroku+json; version=3"' }
      it { should have_logged 'Status: 200' }
    end

    describe 'given --run restart' do
      it { should have_run '[print] Restarting dynos ... ' }
      it { should have_requested :delete, 'https://api.heroku.com/apps/dpl/dynos' }
    end

    describe 'given --run ./cmd' do
      it { should have_run '[print] Running command ./cmd ... ' }
      it { should have_requested(:post, 'https://api.heroku.com/apps/dpl/dynos').with(body: { command: './cmd', attach: true }) }
      it { expect(Rendezvous).to have_received(:start).with(url: 'attach_url') }
    end
  end

  describe 'using --username and --password'  do
    let(:creds) { %w(--username user --password pass) }
    let(:pass) { 'pass' }
    it { should have_written '~/.netrc', netrc }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { |e| %w(--strategy git) }
    env HEROKU_API_KEY: 'key'
    it { expect { subject.run }.to_not raise_error }
  end
end
