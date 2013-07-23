require 'spec_helper'
require 'rhc'
require 'dpl/provider/openshift'

describe DPL::Provider::Openshift do
  subject :provider do
    described_class.new(DummyContext.new, :user => 'foo', :password => 'foo', :domain => 'foo', :app => 'example', :key_name => 'key')
  end

  describe :api do
    it 'accepts a user and a password' do
      api = double(:api)
      provider.options.update(:user => "foo", :password => "bar")
      ::RHC::Rest::Client.should_receive(:new).with(:user => "foo", :password => "bar", :server => "openshift.redhat.com").and_return(api)
      provider.api.should be == api
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
      ::RHC::Rest::Client.should_receive(:new).at_most(:once).and_return(api)
      provider.api
    end

    its(:api) {should be == api}

    describe :check_auth do
      example do
        provider.should_receive(:log).with("authenticated as foo@bar.com")
        provider.check_auth
      end
    end

    describe :check_app do
      example do
        provider.should_receive(:log).with("found app example")
        provider.check_app
      end
    end

    describe :setup_key do
      example do
        File.should_receive(:read).with("the file").and_return("ssh-rsa\nfoo")
        api.should_receive(:add_key).with("key", "foo", "ssh-rsa")
        provider.setup_key("the file")
      end
    end

    describe :remove_key do
      example do
        api.should_receive(:delete_key).with("key")
        provider.remove_key
      end
    end

    describe :push_app do
      example do
        provider.context.should_receive(:shell).with("git push git://something -f")
        provider.push_app
      end
    end

    describe :restart do
      example do
        provider.app.should_receive(:restart)
        provider.restart
      end
    end
  end
end
