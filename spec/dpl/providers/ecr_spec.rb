describe Dpl::Providers::Ecr do
  let(:args) { |e| %W(--access_key_id key --secret_access_key secret --source source:1.0) + args_from_description(e) }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }

  before do
    Aws.config[:ecr] = {
      stub_responses: {
        get_authorization_token: ->(ctx) {
          requests[:get_authorization_token] << ctx.http_request
          region = ctx.http_request.endpoint.to_s.split('.')[2]
          {
            authorization_data: [
              {
                authorization_token: 'dXNlcjpwYXNzCg==',
                proxy_endpoint: "https://account_id.dkr.ecr.#{region}.amazonaws.com"
              }
            ]
          }
        },
        get_deployment: ->(ctx) {
          requests[:get_deployment] << ctx.http_request
          { deployment_info: { status: 'Succeeded' } }
        }
      }
    }
  end

  after { Aws.config.clear }

  matcher :get_authorization_token do |params = {}|
    match { |*| !!requests[:get_authorization_token][0] }
  end

  before { subject.run }

  describe 'given --target one:tag', record: true do
    it { should get_authorization_token }
    it { should have_run '[info] Using Access Key: k*******************' }
    it { should have_run 'docker login -u user -p pass https://account_id.dkr.ecr.us-east-1.amazonaws.com' }
    it { should have_run '[info] Authenticated with https://account_id.dkr.ecr.us-east-1.amazonaws.com' }
    it { should have_run '[info] Setting the build environment up for the deployment' }
    it { should have_run '[info] Pushing image source:1.0 to regions us-east-1 as one:tag' }
    it { should have_run '[info] $ docker tag source:1.0 account_id.dkr.ecr.us-east-1.amazonaws.com/one:tag' }
    it { should have_run 'docker tag source:1.0 account_id.dkr.ecr.us-east-1.amazonaws.com/one:tag' }
    it { should have_run '[info] $ docker push account_id.dkr.ecr.us-east-1.amazonaws.com/one' }
    it { should have_run 'docker push account_id.dkr.ecr.us-east-1.amazonaws.com/one' }
    it { should have_run '[info] Pushed image source:1.0 to region us-east-1 as one:tag' }
    it { should have_run_in_order }
  end

  describe 'given --region us-east-1,us-west-1 --target one:tag,two:tag' do
    it { should have_run 'docker login -u user -p pass https://account_id.dkr.ecr.us-east-1.amazonaws.com' }
    it { should have_run 'docker login -u user -p pass https://account_id.dkr.ecr.us-east-1.amazonaws.com' }

    it { should have_run 'docker tag source:1.0 account_id.dkr.ecr.us-east-1.amazonaws.com/one:tag' }
    it { should have_run 'docker push account_id.dkr.ecr.us-east-1.amazonaws.com/one' }
    it { should have_run 'docker tag source:1.0 account_id.dkr.ecr.us-east-1.amazonaws.com/two:tag' }
    it { should have_run 'docker push account_id.dkr.ecr.us-east-1.amazonaws.com/two' }

    it { should have_run 'docker tag source:1.0 account_id.dkr.ecr.us-west-1.amazonaws.com/one:tag' }
    it { should have_run 'docker push account_id.dkr.ecr.us-west-1.amazonaws.com/one' }
    it { should have_run 'docker tag source:1.0 account_id.dkr.ecr.us-west-1.amazonaws.com/two:tag' }
    it { should have_run 'docker push account_id.dkr.ecr.us-west-1.amazonaws.com/two' }
  end
end
