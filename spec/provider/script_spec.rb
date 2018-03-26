require 'spec_helper'
require 'dpl/provider/script'

describe DPL::Provider::Script do

  subject :provider do
    described_class.new(DummyContext.new, { script: script })
  end

  let(:script) { 'scripts/deploy_script' }

  it 'runs command "script" given' do
    expect(provider.context).to receive(:shell).with(script)
    provider.push_app
  end

  context 'when script exits with nonzero status' do
    before :each do
      # TODO: Found a better way to test this
      Process::Status.any_instance.stub(:exitstatus).and_return(1)
    end

    it 'raises error' do
      expect { provider.push_app }.to raise_error(DPL::Error)
    end
  end
end