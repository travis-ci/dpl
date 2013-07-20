require 'spec_helper'
require 'dpl/provider/dot_cloud'

describe DPL::Provider::DotCloud do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :api_key => 'foo')
  end

  describe :check_auth do
    example do
      provider.context.should_receive(:shell).with("echo foo | dotcloud setup --api-key")
      provider.check_auth
    end
  end

  describe :check_app do
    example do
      provider.context.should_receive(:shell).with("dotcloud connect example")
      provider.check_app
    end
  end

  describe :needs_key? do
    example do
      provider.needs_key?.should == false
    end
  end

  describe :push_app do
    example do
      provider.context.should_receive(:shell).with("dotcloud push example")
      provider.push_app
    end
  end

  describe :run do
    example do
      provider.context.should_receive(:shell).with("dotcloud -A example www test")
      provider.run("test")
    end
  end
end
