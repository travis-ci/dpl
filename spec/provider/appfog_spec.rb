require 'spec_helper'
require 'dpl/provider/appfog'

describe DPL::Provider::Appfog do
  subject :provider do
    described_class.new(DummyContext.new, :email => 'blah@foo.com', :password => 'bar')
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with("af login --email=blah@foo.com --password=bar")
      provider.check_auth
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "Without :app" do
      expect(provider.context).to receive(:shell).with("af update dpl")
      expect(provider.context).to receive(:shell).with("af logout")
      provider.push_app
    end
    example "With :app" do
      provider.options.update(:app => 'test')
      expect(provider.context).to receive(:shell).with("af update test")
      expect(provider.context).to receive(:shell).with("af logout")
      provider.push_app
    end
  end
end
