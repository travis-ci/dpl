require 'spec_helper'

describe DPL::Provider::Script do

  subject :provider do
    described_class.new(DummyContext.new, {})
  end

  let(:script) { 'scripts/deploy_script' }

  it 'runs command "script" given' do
    provider.options.update( script: script )
    expect(provider.context).to receive(:shell).with(script)
    provider.push_app
  end
end