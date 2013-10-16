require 'spec_helper'
require 'aws-sdk'
require 'dpl/provider/s3'

describe DPL::Provider::S3 do
  
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
    example do
      provider.push_app
    end
  end

  describe :api do   
    example do
      AWS::S3.should_receive(:new)
      provider.api
    end
  end
end
