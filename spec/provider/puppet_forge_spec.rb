require 'spec_helper'
require 'dpl/provider/puppet_forge'
require 'puppet/face'
require 'puppet_blacksmith'

describe DPL::Provider::PuppetForge do
  subject :provider do
    described_class.new(DummyContext.new, :user => 'puppetlabs', :password => 's3cr3t')
  end

  describe "forge" do
    it 'should include the user and password specified' do
      expect(provider.forge.username).to eq(provider.options[:user])
      expect(provider.forge.password).to eq(provider.options[:password])
    end
  end

  describe "build" do
    it 'should use Puppet module tool to build the module' do
      pmt = double('pmt')
      expect(::Puppet::Face).to receive(:[]).and_return(pmt)
      expect(pmt).to receive(:build).with('./')
      provider.build
    end
  end

  describe "#check_auth" do
    it 'should require a user' do
      provider.options.update(:user => nil)
      expect{ provider.check_auth }.to raise_error("must supply a user")
    end

    it 'should require a password' do
      provider.options.update(:password => nil)
      expect{ provider.check_auth }.to raise_error("must supply a password")
    end
  end

  describe "#check_app" do
    it 'should load module metadata using Blacksmith' do
      modulefile = double('modulefile')
      expect(::Blacksmith::Modulefile).to receive(:new).and_return(modulefile)
      expect(modulefile).to receive(:metadata) { true }
      provider.check_app
    end
  end

  describe "#push_app" do
    it 'should use Blacksmith to push to the Forge' do
      forge = double('forge')
      expect(provider).to receive(:build).and_return(true)
      expect(provider).to receive(:modulefile).at_least(:once).and_return(double('modulefile', :name => 'test'))
      expect(provider).to receive(:log).and_return(true)
      expect(::Blacksmith::Forge).to receive(:new).and_return(forge)
      expect(forge).to receive(:push!) { true }
      expect(forge).to receive(:username) { provider.options[:user] }
      provider.push_app
    end
  end
end
