require 'spec_helper'
require 'dpl/provider/npm'

describe DPL::Provider::NPM do
  subject :provider do
    described_class.new(DummyContext.new, :email => 'foo@blah.com', :api_key => 'test')
  end

  describe :check_auth do
    example do
      provider.should_receive(:setup_auth)
      provider.should_receive(:log).with("Authenticated with email foo@blah.com")
      provider.check_auth
    end
  end

  describe :push_app do
    example do
      provider.context.should_receive(:shell).with("npm publish --force")
      provider.push_app
    end
  end

  describe :setup_auth do
    example do
      f = double(:npmrc)
      File.should_receive(:open).with(File.expand_path(DPL::Provider::NPM::NPMRC_FILE)).and_return(f)
      f.should_receive(:puts).with("_auth = test")
      f.should_receive(:puts).with("email = foo@blah.com")
      provider.setup_auth
    end
  end
end
