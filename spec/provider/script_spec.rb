require 'spec_helper'

describe DPL::Provider::Script do

  subject :provider do
    described_class.new(DummyContext.new, { script: script })
  end

  let(:script) { 'scripts/deploy_script' }

  before :each do
    stdin, stdout, stderr, wait_thr = double('stdin'), double('stdout'), double('stderr'), double('wait_thr')
    @status = double

    allow(stdout).to receive(:read)
    allow(stderr).to receive(:read)
    allow(wait_thr).to receive(:status).and_return(false)
    allow(wait_thr).to receive(:value).and_return(@status)
    allow(@status).to receive(:success?).and_return(true)

    expect(Open3).to receive(:popen3).and_return([stdin, stdout, stderr, wait_thr])
  end

  it 'runs command "script" given' do
    provider.push_app
  end

  context 'when script exits with nonzero status' do
    before :each do
      # TODO: Found a better way to test this
      allow(@status).to receive(:success?).and_return(false)
      allow(@status).to receive(:exitstatus).and_return(1)
    end

    it 'raises error' do
      expect { provider.push_app }.to raise_error(DPL::Error)
    end
  end
end