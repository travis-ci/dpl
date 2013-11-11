require 'spec_helper'
require 'dpl/provider/cloud_files'
require 'fog'

describe DPL::Provider::CloudFiles do
  before :each do
    Fog.mock!
  end

  subject :provider do
    described_class.new(DummyContext.new, :username => 'username', :api_key => 'api key', :container => 'travis', :region => 'dfw')
  end

  describe :needs_key? do
    example do
      provider.needs_key?.should == false
    end
  end

  describe :api do
    example do
      Fog::Storage.should_receive(:new).with(:provider => 'Rackspace', :rackspace_username => 'username', :rackspace_api_key => 'api key', :rackspace_region => 'dfw')

      provider.api
    end
  end

  describe :check_auth do
    example do
      provider.should_receive(:log).with('Authenticated as username')

      provider.check_auth
    end
  end

  describe :push_app do
    let :files do
      files = double

      directory = double
      directory.stub(:files) { files }

      directories = double
      directories.should_receive(:get).with('travis').and_return(directory)

      service = double(:service)
      service.stub(:directories) { directories }
      provider.stub(:api) { service }

      files
    end

    example do
      files.should_receive(:create).with(:key => 'a', :body => 'a body')
      files.should_receive(:create).with(:key => 'b', :body => 'b body')
      files.should_receive(:create).with(:key => 'c', :body => 'c body')

      Dir.should_receive(:glob).with('**/*').and_return(['a', 'b', 'c'])
      File.stub(:open) { |name| "#{name} body" }

      provider.push_app
    end
  end

  describe :deploy do
    example 'Not Found' do
      directories = double
      directories.stub(:get) { nil }

      service = double(:service)
      service.stub(:directories) { directories }
      provider.stub(:api) { service }

      expect { provider.deploy }.to raise_error(DPL::Error, 'The specified container does not exist.')
    end
  end
end
