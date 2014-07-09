require 'spec_helper'
require 'dpl/provider/cloud66'

describe DPL::Provider::Cloud66 do
  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  let(:successful_response){ double(code: '200') }
  let(:not_found_response){ double(code: '404') }
  let(:options){ {} }

  describe "#push_app" do
    context 'with a successful response' do
      let(:options){ {:redeployment_hook => 'https://hooks.cloud66.com/stacks/redeploy/0101010101010101'} }

      example do
        expect(provider).to receive(:webhook_call).with('https', 'hooks.cloud66.com', 443, '/stacks/redeploy/0101010101010101').and_return(successful_response)
        provider.push_app
      end
    end

    context 'with a 404 response' do
      let(:options){ {:redeployment_hook => 'https://hooks.cloud66.com/stacks/redeploy/0101010101010101'} }

      it 'should raise an error' do
        expect(provider).to receive(:webhook_call).with('https', 'hooks.cloud66.com', 443, '/stacks/redeploy/0101010101010101').and_return(not_found_response)
        expect { provider.push_app }.to raise_error(DPL::Error, "Redeployment failed [404]")
      end
    end

    context 'with missing redeployment_hook option' do
      it 'should raise an error' do
        expect { provider.push_app }.to raise_error(DPL::Error, "missing redeployment_hook")
      end
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end
end
