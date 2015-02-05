require 'spec_helper'
require 'dpl/provider/appengine'

describe DPL::Provider::AppEngine do
  subject :provider do
    described_class.new(DummyContext.new, :user => "foo", :password => "bar")
  end

  let(:oauth_token) { "TOKEN" }

  describe "#setup_auth" do
    example do
      expect(provider.context).to receive(:shell).with("gcloud auth activate-refresh-token TOKEN")
      provider.setup_auth
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "Without :app" do
      expect(provider.context).to receive(:shell).with("gcloud preview app deploy .")
      provider.push_app
    end
  end
end
