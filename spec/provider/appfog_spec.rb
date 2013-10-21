require 'spec_helper'
require 'dpl/provider/appfog'

describe DPL::Provider::Appfog do
  subject :provider do
    described_class.new(DummyContext.new, :email => 'blah@foo.com', :password => 'bar')
  end

  describe :check_auth do
    example do
      provider.context.should_receive(:shell).with("af login --email=blah@foo.com --password=bar")
      provider.check_auth
    end
  end

  describe :needs_key? do
    example do
      provider.needs_key?.should == false
    end
  end

  describe :push_app do
    example "Without :app" do
      provider.context.should_receive(:shell).with("af update dpl")
      provider.context.should_receive(:shell).with("af logout")
      provider.push_app
    end
    example "With :app" do
      provider.options.update(:app => 'test')
      provider.context.should_receive(:shell).with("af update test")
      provider.context.should_receive(:shell).with("af logout")
      provider.push_app
    end
  end
end
