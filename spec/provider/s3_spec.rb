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

  describe :upload_path do
    example "Without :upload_dir"do
      filename = "testfile.file"

      provider.upload_path(filename).should == "testfile.file"
    end

    example "With :upload_dir" do
      provider.options.update(:upload_dir => 'BUILD3')
      filename = "testfile.file"

      provider.upload_path(filename).should == "BUILD3/testfile.file"
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
    example "Without local_dir" do
      Dir.should_receive(:chdir).with(Dir.pwd)
      provider.push_app
    end

    example "With local_dir" do
      provider.options.update(:local_dir => 'BUILD')
      
      Dir.should_receive(:chdir).with('BUILD')
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
