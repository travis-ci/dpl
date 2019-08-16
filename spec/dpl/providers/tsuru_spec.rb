describe Dpl::Providers::Tsuru do
  let(:args) { |e| %w(--email email --password pass --server http://server.url) + args_from_description(e) }
  let(:headers) { { 'Authorization' => 'Bearer token' } }
  let(:user) { { token: 'token' } }
  let(:app)  { {} }

  before { stub_request(:post, %r(/auth/login$)).and_return(body: JSON.dump(user)) }
  before { stub_request(:get, %r(/apps/.+$)).and_return(body: JSON.dump(app)) }
  before { stub_request(:post, %r(/users/keys$)) }
  before { stub_request(:delete, %r(/users/keys/.+$)) }

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[info] Found app dpl' }
    it { should have_run '[info] $ git push --force HEAD:master' }
    it { should have_run 'git push --force HEAD:master' }
    it { should have_run_in_order }

    it { should have_requested(:post, %r(/auth/login)).with(body: 'email=email&password=pass')}
    it { should have_requested(:get, %r(/apps/dpl)).with(headers: headers)}
    it { should have_requested(:post, %r(/users/keys)).with(body: 'name=dpl_deploy_key&key=ssh-rsa+public-key', headers: headers)}
    it { should have_requested(:delete, %r(/users/keys/dpl_deploy_key)).with(headers: headers)}
  end

  describe 'given --app app' do
    it { should have_requested(:get, %r(/apps/app)).with(headers: headers)}
  end

  describe 'given --key_name name' do
    it { should have_requested(:post, %r(/users/keys)).with(body: 'name=name&key=ssh-rsa+public-key', headers: headers)}
    it { should have_requested(:delete, %r(/users/keys/name)).with(headers: headers)}
  end

  describe 'given --refspec ref:spec' do
    it { should have_run '[info] $ git push --force ref:spec' }
    it { should have_run 'git push --force ref:spec' }
  end
end

