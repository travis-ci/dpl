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
      expect(provider.context).to receive(:shell).with("env NPM_API_KEY=test npm publish")
      expect(FileUtils).to receive(:rm).with(File.expand_path(DPL::Provider::NPM::NPMRC_FILE))
      provider.push_app
    end
  end

  describe "#setup_auth" do
    example do
      test_setup_auth
    end
  end

  context 'when package.json exists' do
    let(:custom_rpm_registry) { 'npm.example.com' }
    before :each do
      expect(File).to receive(:exists?).with('package.json').and_return(true)
    end

    context 'and it defines custom RPM registry' do
      before { expect(File).to receive(:read).with('package.json').and_return("{\"publishConfig\":{\"registry\":\"#{custom_rpm_registry}\"}}") }

      describe '#setup_auth' do
        example do
          test_setup_auth(custom_rpm_registry)
        end
      end
    end

    context 'and it does not define custom RPM registry' do
      before { expect(File).to receive(:read).with('package.json').and_return("{}") }

      describe '#setup_auth' do
        example do
          test_setup_auth
        end
      end
    end
  end
end

def test_setup_auth(registry=DPL::Provider::NPM::DEFAULT_NPM_REGISTRY)
  f = double(:npmrc)
  expect(File).to receive(:open).with(File.expand_path(DPL::Provider::NPM::NPMRC_FILE), 'w').and_return(f)
  expect(f).to receive(:puts).with("//#{registry}/:_authToken=${NPM_API_KEY}")
  allow(f).to receive(:flush)
  provider.setup_auth
end
