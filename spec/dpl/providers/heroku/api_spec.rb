# frozen_string_literal: true

describe Dpl::Providers::Heroku do
  let(:args) { |e| %w[--strategy api --api_key key] + args_from_description(e) }
  let(:user) { JSON.dump(email: 'email') }
  let(:dyno) { JSON.dump(attach_url: 'attach_url') }
  let(:urls) { JSON.dump(source_blob: { get_url: 'get_url', put_url: 'put_url' }) }
  let(:build) { JSON.dump(id: 1, output_stream_url: 'output_stream_url', status: 'succeeded') }

  before do
    stub_request(:get, 'https://api.heroku.com/account').and_return(body: user)
    stub_request(:post, 'https://api.heroku.com/sources').and_return(body: urls)
    stub_request(:get, 'https://api.heroku.com/apps/dpl')
    stub_request(:post, 'https://api.heroku.com/apps/dpl/builds').and_return(body: build)
    stub_request(:get, 'https://api.heroku.com/apps/dpl/builds/1').and_return(body: build)
  end

  before { |c| subject.run if run?(c) }

  # remaining options are tested in heroku/git_spec.rb

  describe 'by default', record: true do
    it { is_expected.to have_run '[print] Authenticating ... ' }
    it { is_expected.to have_run '[print] Checking for app dpl ... ' }
    it { is_expected.to have_run '[info] Creating application archive' }
    it { is_expected.to have_run %r{tar -zcf .*/.dpl.dpl.tgz --exclude \.git \.} }
    it { is_expected.to have_run '[info] Uploading application archive' }
    it { is_expected.to have_run %r{curl -sS put_url -X PUT -H "Content-Type:" -H "Accept: application/vnd.heroku\+json; version=3" -H "User-Agent: .*dpl/.*" --data-binary @.*/.dpl.dpl.tgz} }
    it { is_expected.to have_run '[info] Triggering Heroku build (deployment)' }
    it { is_expected.to have_run %r{curl -sS output_stream_url -H "Accept: application/vnd.heroku\+json; version=3" -H "User-Agent: .*dpl/.*"} }
    it { is_expected.to have_run_in_order }

    it { is_expected.to have_requested :get, 'https://api.heroku.com/account' }
    it { is_expected.to have_requested :post, 'https://api.heroku.com/sources' }
    it { is_expected.to have_requested :get, 'https://api.heroku.com/apps/dpl' }
    it { is_expected.to have_requested(:post, 'https://api.heroku.com/apps/dpl/builds').with(body: { source_blob: { url: 'get_url', version: 'sha' } }) }
    it { is_expected.to have_requested :get, 'https://api.heroku.com/apps/dpl/builds/1' }
  end

  describe 'given --version version' do
    it { is_expected.to have_requested(:post, 'https://api.heroku.com/apps/dpl/builds').with(body: { source_blob: { url: 'get_url', version: 'version' } }) }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { |_e| %w[--strategy api] }

    env HEROKU_API_KEY: 'key'
    it { expect { subject.run }.not_to raise_error }
  end
end
