require 'spec_helper'
require 'dpl/provider/npm'

describe DPL::Provider::NPM do
  subject :provider do
    described_class.new(DummyContext.new, :email => 'foo@blah.com', :api_key => 'test')
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:setup_auth)
      expect(provider).to receive(:log).with("Authenticated with email foo@blah.com")
      provider.check_auth
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with("npm publish")
      provider.push_app
    end
  end

  describe "#setup_auth" do
    example do
      f = double(:npmrc)
      expect(File).to receive(:open).with(File.expand_path(DPL::Provider::NPM::NPMRC_FILE)).and_return(f)
      expect(f).to receive(:puts).with("_auth = test")
      expect(f).to receive(:puts).with("email = foo@blah.com")
      provider.setup_auth
    end
  end
end
