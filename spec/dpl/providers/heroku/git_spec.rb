# frozen_string_literal: true

describe Dpl::Providers::Heroku do
  let(:args) { |e| %w[--strategy git] + creds + args_from_description(e) }
  let(:user) { JSON.dump(email: 'email') }
  let(:dyno) { JSON.dump(attach_url: 'attach_url') }
  let(:pass) { 'key' }

  let(:netrc) do
    sq(<<-RC)
      machine git.heroku.com
        login email
        password #{pass}
    RC
  end

  before do
    stub_request(:get, 'https://api.heroku.com/account').and_return(body: user)
    stub_request(:get, 'https://api.heroku.com/apps/dpl')
    stub_request(:get, 'https://api.heroku.com/apps/other')
    stub_request(:post, 'https://api.heroku.com/apps/dpl/dynos').and_return(body: dyno)
    stub_request(:delete, 'https://api.heroku.com/apps/dpl/dynos')
    allow(Rendezvous).to receive(:start)
  end

  before { |c| subject.run if run?(c) }

  describe 'using --api_key' do
    let(:creds) { %w[--api_key key] }

    describe 'by default', record: true do
      it { is_expected.to have_run '[print] Authenticating ... ' }
      it { is_expected.to have_run '[print] Checking for app dpl ... ' }
      it { is_expected.to have_run 'git fetch origin $TRAVIS_BRANCH --unshallow' }
      it { is_expected.to have_run 'git push https://git.heroku.com/dpl.git HEAD:refs/heads/master -f' }
      it { is_expected.to have_requested :get, 'https://api.heroku.com/account' }
      it { is_expected.to have_requested :get, 'https://api.heroku.com/apps/dpl' }
      it { is_expected.to have_run_in_order }
      it { is_expected.to have_written '~/.netrc', netrc }
    end

    describe 'given --app other' do
      it { is_expected.to have_run '[print] Checking for app other ... ' }
      it { is_expected.to have_run 'git push https://git.heroku.com/other.git HEAD:refs/heads/master -f' }
      it { is_expected.to have_requested :get, 'https://api.heroku.com/apps/other' }
    end

    describe 'given --log_level debug' do
      it { is_expected.to have_logged 'get https://api.heroku.com/account' }
      it { is_expected.to have_logged 'Accept: "application/vnd.heroku+json; version=3"' }
      it { is_expected.to have_logged 'Status: 200' }
    end

    describe 'given --run restart' do
      it { is_expected.to have_run '[print] Restarting dynos ... ' }
      it { is_expected.to have_requested :delete, 'https://api.heroku.com/apps/dpl/dynos' }
    end

    describe 'given --run ./cmd' do
      it { is_expected.to have_run '[print] Running command ./cmd ... ' }
      it { is_expected.to have_requested(:post, 'https://api.heroku.com/apps/dpl/dynos').with(body: { command: './cmd', attach: true }) }
      it { expect(Rendezvous).to have_received(:start).with(url: 'attach_url') }
    end
  end

  describe 'using --username and --password' do
    let(:creds) { %w[--username user --password pass] }
    let(:pass) { 'pass' }

    it { is_expected.to have_written '~/.netrc', netrc }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { |_e| %w[--strategy git] }

    env HEROKU_API_KEY: 'key'
    it { expect { subject.run }.not_to raise_error }
  end
end
