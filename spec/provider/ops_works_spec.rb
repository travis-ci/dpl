require 'spec_helper'
require 'aws-sdk'
require 'dpl/provider'
require 'dpl/provider/ops_works'

describe DPL::Provider::OpsWorks do

  before (:each) do
    AWS.stub!
  end

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :bucket => 'my-bucket')
  end

  describe :check_auth do
    example do
      provider.should_receive(:setup_auth)
      provider.should_receive(:log).with("Logging in with Access Key: ****************jklz")
      provider.check_auth
    end
  end

  describe :setup_auth do
    example do
      AWS.should_receive(:config).with(:access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz').once.and_call_original
      provider.setup_auth
    end
  end

  describe :needs_key? do
    example do
      provider.needs_key?.should == false
    end
  end

  describe :push_app do
    let(:client) { double(:ops_works_client) }
    example do
      provider.options.update(stack_id: 'stack-id', app_id: 'app-id')
      provider.api.should_receive(:client).and_return(client)
      client.should_receive(:create_deployment).with(stack_id: 'stack-id', app_id: 'app-id', command: {name: "deploy"})
      provider.push_app
    end
  end

  describe :api do
    example do
      AWS::OpsWorks.should_receive(:new)
      provider.api
    end
  end
end
