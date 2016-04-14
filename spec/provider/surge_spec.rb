require 'spec_helper'
require 'dpl/provider/surge'

describe DPL::Provider::Surge do
  subject :provider do
    described_class.new(DummyContext.new, :project => './', :domain => 'mydomain')
  end
 
  describe "#push_app" do
    it 'should peforme a surge command with correct project and domain set' do
      expect(provider.context).to receive(:shell).with("surge " + File.expand_path('./') + " mydomain")
      provider.push_app
    end
  end
end
