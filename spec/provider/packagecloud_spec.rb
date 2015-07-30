require 'spec_helper'
require 'rubygems'
require 'gems'
require 'dpl/provider/packagecloud'

describe DPL::Provider::Packagecloud do

  subject :provider do
    described_class.new(DummyContext.new, :username => 'joedamato', :repository => 'test_repo', :token => 'test_token')
  end

  describe "#setup_auth" do
    it 'should get username and token' do
      expect(provider).to receive(:log).with("Logging into https://packagecloud.io with joedamato:****************oken")
      provider.setup_auth
    end

    it 'should require username' do
      new_provider = described_class.new(DummyContext.new, {:token => 'test_token'})
      expect{ new_provider.setup_auth }.to raise_error("missing username")
    end

    it 'should require token' do
      new_provider = described_class.new(DummyContext.new, {:username => 'test_token'})
      expect{ new_provider.setup_auth }.to raise_error("missing token")
    end

    it 'should require repository' do
      new_provider = described_class.new(DummyContext.new, {:username => 'joedamato', :token => 'test_token'})
      expect{ new_provider.setup_auth }.to raise_error("missing repository")
    end

  end

  describe "#push_app" do
    it 'defaults to searching everywhere' do
      expect(Dir).to receive(:glob).with('**/*')
      expect { provider.push_app }.to raise_error(DPL::Error)
    end

    it 'accepts and uses a string glob' do
      provider.options.update(:package_glob => 'foo*.gem')

      expect(Dir).to receive(:glob).with('foo*.gem')
      expect { provider.push_app }.to raise_error(DPL::Error)
    end

    it 'accepts and uses an array of globs' do
      provider.options.update(:package_glob => ['*.rpm', '**/*.deb'])

      expect(Dir).to receive(:glob).with('*.rpm', '**/*.deb')
      expect { provider.push_app }.to raise_error(DPL::Error)
    end
  end

end
