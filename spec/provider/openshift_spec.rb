require 'spec_helper'
require 'rhc'
require 'dpl/provider/openshift'

describe DPL::Provider::Openshift do
  subject :provider do
    described_class.new(DummyContext.new, :user => 'foo', :password => 'foo', :domain => 'foo', :app => 'example', :key_name => 'key')
  end

  describe "#api" do
    it 'accepts a user and a password' do
      api = double(:api)
      provider.options.update(:user => "foo", :password => "bar")
      expect(::RHC::Rest::Client).to receive(:new).with(:user => "foo", :password => "bar", :server => "openshift.redhat.com").and_return(api)
      expect(provider.api).to eq(api)
    end
  end

  context "with api" do
    let :api do
      double "api",
        :user => double(:login => "foo@bar.com"),
        :find_application => double(:name => "example", :git_url => "git://something"),
        :add_key => double
    end
    let :app do
      double "app",
        :restart => double
    end

    before do
      expect(::RHC::Rest::Client).to receive(:new).at_most(:once).and_return(api)
      provider.api
    end

    its(:api) {should be == api}

    describe "#check_auth" do
      example do
        expect(provider).to receive(:log).with("authenticated as foo@bar.com")
        provider.check_auth
      end
    end

    describe "#check_app" do
      example do
        expect(provider).to receive(:log).with("found app example")
        provider.check_app
      end
    end

    describe "#setup_key" do
      example do
        expect(File).to receive(:read).with("the file").and_return("ssh-rsa\nfoo")
        expect(api).to receive(:add_key).with("key", "foo", "ssh-rsa")
        provider.setup_key("the file")
      end
    end

    describe "#remove_key" do
      example do
        expect(api).to receive(:delete_key).with("key")
        provider.remove_key
      end
    end

    describe "#push_app" do
      example "when app.deployment_branch is not set" do
        expect(provider.context).to receive(:shell).with("git push git://something -f")
        provider.push_app
      end
    end

    context "when app.deployment_branch is set" do
      subject :provider do
        described_class.new(DummyContext.new, :user => 'foo', :password => 'foo', :domain => 'foo', :app => 'example', :key_name => 'key', :deployment_branch => 'test-branch')

      expect(provider.app).to receive(:deployment_branch=).with("test-branch")
      expect(provider.context).to receive(:shell).with("git push git://something -f test-branch")
      provider.push_app
      end
    end

    describe "#restart" do
      example do
        expect(provider.app).to receive(:restart)
        provider.restart
      end
    end
  end
end
