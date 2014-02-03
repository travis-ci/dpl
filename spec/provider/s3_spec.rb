require 'spec_helper'
require 'aws-sdk'
require 'dpl/provider/s3'

describe DPL::Provider::S3 do
  
  before (:each) do
    AWS.stub!
  end
  
  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :bucket => 'my-bucket', :s3_options => {:acl => :private})
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
    example "Without :region" do
      AWS.should_receive(:config).with(:access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :region => 'us-east-1').once.and_call_original
      provider.setup_auth
    end
    example "With :region" do
      provider.options.update(:region => 'us-west-2')

      AWS.should_receive(:config).with(:access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :region => 'us-west-2').once
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

    example "Sends MIME type" do
      Dir.should_receive(:glob).and_yield(__FILE__)
      AWS::S3::ObjectCollection.any_instance.should_receive(:create).with(anything(), anything(), hash_including(:content_type => 'application/x-ruby'))
      provider.push_app
    end

    context "When s3_options are given" do
      let :object_collection do
        double('object collection')
      end

      before do
        provider.options.update(
          :s3_options => {:acl => :public_read},
          :bucket => "foo"
        )
        File.stub(:read).with("testfile.file").and_return("testfile content")
        Dir.stub(:glob).and_yield("testfile.file")
        File.stub(:directory?).with("testfile.file").and_return(false)
        provider.api.stub_chain(:buckets, :[], :objects)
                .and_return(object_collection)
      end

      example "With s3_options acl public_read" do
        object_collection.should_receive(:create).with(
          provider.upload_path("testfile.file"), "testfile content",
          hash_including(:acl => :public_read)
        )
        provider.push_app
      end
    end
  end

  describe :api do   
    example "Without Endpoint" do
      AWS::S3.should_receive(:new).with(:endpoint => 's3.amazonaws.com')
      provider.api
    end
    example "With Endpoint" do
      provider.options.update(:endpoint => 's3test.com.s3-website-us-west-2.amazonaws.com')
      AWS::S3.should_receive(:new).with(:endpoint => 's3test.com.s3-website-us-west-2.amazonaws.com')
      provider.api
    end
  end
end
