require 'spec_helper'
require 'dpl/provider/apm'

describe DPL::Provider::APM do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :api_key => 'foo')
  end

  describe '#api' do
    example 'with an api key' do
      expect(::Gems).to receive(:key=).with('foo')
      provider.setup_auth
    end
  end
end
