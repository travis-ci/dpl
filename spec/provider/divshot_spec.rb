require 'spec_helper'
require 'dpl/provider/divshot'

describe DPL::Provider::Divshot do
  subject :provider do
    described_class.new DummyContext.new, :api_key => 'abc123'
  end

  describe "#check_auth" do
    it 'should require an api key' do
      provider.options.update(:api_key => nil)
      expect{ provider.check_auth }.to raise_error("must supply an api key")
    end
  end

  describe "#push_app" do
    it 'should include the environment specified' do
      provider.options.update(:environment => 'development')
      expect(provider.context).to receive(:shell).with("divshot push development --token abc123")
      provider.push_app
    end

    it 'should default to production' do
      expect(provider.context).to receive(:shell).with("divshot push production --token abc123")
      provider.push_app
    end
  end
end