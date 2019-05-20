describe Dpl::Providers::Engineyard do
  let(:args)    { |e| args_from_description(e) }
  let(:headers) { { content_type: 'application/json' } }

  def response(key)
    { body: fixture(:engineyard, key), status: 200, headers: headers }
  end

  before do
    stub_request(:post, %r(/authenticate)).to_return(response(:auth))
    stub_request(:get,  %r(/current_user)).to_return(response(:user))
    stub_request(:get,  %r(/app_environments)).to_return(response(:app_env_one))
    stub_request(:post, %r(/deploy)).to_return(response(:deploy))
    stub_request(:get,  %r(/deployments/\d+)).to_return(response(:deployment))
  end

  describe 'given --api_key key' do
    before { subject.run }
    it { should have_run '[info] Authenticated as test@test.test' }
    it { should have_run '[print] Deploying ...' }
    it { should have_run '[print] .' }
    it { should have_run '[info] Done: https://cloud.engineyard.com/apps/7/environments/7/deployments/2/pretty' }
  end

  describe 'given --email email --password password' do
    before { subject.run }
    it { should have_run '[info] Authenticated as test@test.test' }
  end

  describe 'no credentials' do
    it { expect { subject.run }.to raise_error 'Missing options: api_key, or email and password' }
  end

  # These are rather hard to test in a more meaningful way, as they are passed
  # to the EY Ruby client, which returns an OOP representation of the API
  # response. This would require lots of stubbing ...
  context do
    let(:args) { |e| %w(--api_key key) + args_from_description(e) }
    before { subject.run }

    describe 'given --app app' do
      it { should have_attributes app: 'app' }
    end

    describe 'given --environment env' do
      it { should have_attributes environment: 'env' }
    end

    describe 'given --migrate cmd' do
      it { should have_attributes migrate: 'cmd' }
    end

    describe 'given --account account' do
      it { should have_attributes account: 'account' }
    end
  end

  describe 'no env matches, given --api_key key' do
    before { stub_request(:get, %r(/app_environments)).to_return(response(:app_env_none)) }
    it { expect { subject.run }.to raise_error /No environment found matching/ }
  end

  describe 'multiple envs match, given --api_key key' do
    before { stub_request(:get, %r(/app_environments)).to_return(response(:app_env_multi)) }
    it { expect { subject.run }.to raise_error /Multiple matches possible/ }
  end
end

