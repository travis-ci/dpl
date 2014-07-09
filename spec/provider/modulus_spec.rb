require 'spec_helper'
require 'dpl/provider/modulus'

describe DPL::Provider::Modulus do
  subject :provider do
    described_class.new(DummyContext.new, :api_key => 'test-token', :project_name => 'test-project')
  end

  describe "#check_auth" do
    it 'should require an api key' do
      provider.options.update(:api_key => nil)
      expect{ provider.check_auth }.to raise_error("must supply an api key")
    end
  end

  describe "#check_app" do
    it 'should require a project name' do
      provider.options.update(:project_name => nil)
      expect{ provider.check_app }.to raise_error("must supply a project name")
    end
  end

  describe "#push_app" do
    it 'should include the api key and project name specified' do
      expect(provider.context).to receive(:shell).with("MODULUS_TOKEN=test-token modulus deploy -p test-project")
      provider.push_app
    end
  end
end
