require 'spec_helper'
require 'dpl/provider/appengine'

describe DPL::Provider::AppEngine do
  subject :provider do
    described_class.new(DummyContext.new, :account => "user@gmail.com", :oauth_token => "TOKEN")
  end

  describe "#install_sdk" do
    example do
      expect(provider.context).to receive(:shell).with("wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip")
      expect(provider.context).to receive(:shell).with("unzip -o -q google-cloud-sdk.zip")
      expect(provider.context).to receive(:shell).with("google-cloud-sdk/install.sh --usage-reporting false --path-update false --rc-path~/.bashrc --bash-completion false --override-components=app")
      provider.install_sdk
    end
  end

  describe "#setup_auth" do
    example do
      expect(provider.context).to receive(:shell).with("gcloud auth activate-refresh-token user@gmail.com TOKEN")
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
