describe Dpl::Providers::Heroku do
  let(:args) { |e| %w(--strategy api --api_key key) + args_from_description(e) }
  let(:user) { JSON.dump(email: 'email') }
  let(:dyno) { JSON.dump(attach_url: 'attach_url') }
  let(:urls) { JSON.dump(source_blob: { get_url: 'get_url', put_url: 'put_url' })}
  let(:build) { JSON.dump(id: 1, output_stream_url: 'output_stream_url', status: 'succeeded') }

  before { stub_request(:get, 'https://api.heroku.com/account').and_return(body: user) }
  before { stub_request(:post, 'https://api.heroku.com/sources').and_return(body: urls) }
  before { stub_request(:get, 'https://api.heroku.com/apps/dpl') }
  before { stub_request(:post, 'https://api.heroku.com/apps/dpl/builds').and_return(body: build) }
  before { stub_request(:get, 'https://api.heroku.com/apps/dpl/builds/1').and_return(body: build) }
  before { |c| subject.run if run?(c) }

  # remaining options are tested in heroku/git_spec.rb

  describe 'by default', record: true do
    it { should have_run '[print] Authenticating ... ' }
    it { should have_run '[print] Checking for app dpl ... ' }
    it { should have_run '[info] Creating application archive' }
    it { should have_run %r(tar -zcf .*/.dpl.dpl.tgz --exclude \.git \.) }
    it { should have_run '[info] Uploading application archive' }
    it { should have_run %r(curl -sS put_url -X PUT -H "Content-Type:" -H "Accept: application/vnd.heroku\+json; version=3" -H "User-Agent: .*dpl/.*" --data-binary @.*/.dpl.dpl.tgz) }
    it { should have_run '[info] Triggering Heroku build (deployment)' }
    it { should have_run %r(curl -sS output_stream_url -H "Accept: application/vnd.heroku\+json; version=3" -H "User-Agent: .*dpl/.*") }
    it { should have_run_in_order }

    it { should have_requested :get, 'https://api.heroku.com/account' }
    it { should have_requested :post, 'https://api.heroku.com/sources' }
    it { should have_requested :get, 'https://api.heroku.com/apps/dpl' }
    it { should have_requested(:post, 'https://api.heroku.com/apps/dpl/builds').with(body: { source_blob: { url: 'get_url', version: 'sha' } }) }
    it { should have_requested :get, 'https://api.heroku.com/apps/dpl/builds/1' }
  end

  describe 'given --version version' do
    it { should have_requested(:post, 'https://api.heroku.com/apps/dpl/builds').with(body: { source_blob: { url: 'get_url', version: 'version' } }) }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { |e| %w(--strategy api) }
    env HEROKU_API_KEY: 'key'
    it { expect { subject.run }.to_not raise_error }
  end
end
