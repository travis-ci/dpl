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

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#api" do
    example do
      expect(Fog::Storage).to receive(:new).with(:provider => 'Rackspace', :rackspace_username => 'username', :rackspace_api_key => 'api key', :rackspace_region => 'dfw')

      provider.api
    end
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:log).with('Authenticated as username')

      provider.check_auth
    end
  end

  describe "#push_app" do
    let :files do
      files = double

      directory = double
      allow(directory).to receive(:files) { files }

      directories = double
      expect(directories).to receive(:get).with('travis').and_return(directory)

      service = double(:service)
      allow(service).to receive(:directories) { directories }
      allow(provider).to receive(:api) { service }

      files
    end

    example do
      expect(files).to receive(:create).with(:key => 'a', :body => 'a body')
      expect(files).to receive(:create).with(:key => 'b', :body => 'b body')
      expect(files).to receive(:create).with(:key => 'c', :body => 'c body')

      expect(Dir).to receive(:glob).with('**/*').and_return(['a', 'b', 'c'])
      allow(File).to receive(:open) { |name| "#{name} body" }

      provider.push_app
    end
  end

  describe "#deploy" do
    example 'Not Found' do
      directories = double
      allow(directories).to receive(:get) { nil }

      service = double(:service)
      allow(service).to receive(:directories) { directories }
      allow(provider).to receive(:api) { service }

      expect { provider.deploy }.to raise_error(DPL::Error, 'The specified container does not exist.')
    end
  end
end
