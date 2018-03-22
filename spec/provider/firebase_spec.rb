require 'spec_helper'
require 'dpl/provider/firebase'

describe DPL::Provider::Firebase do
  subject :provider do
    described_class.new DummyContext.new, :token => 'abc123'
  end

  let(:deploy_dir) { Dir.pwd }

  describe "#check_auth" do
    it 'should require a token if no FIREBASE_TOKEN is set' do
      provider.options.update(:token => nil)
      expect{ provider.check_auth }.to raise_error("must supply token option or FIREBASE_TOKEN environment variable")
    end

    it 'should allow no token if FIREBASE_TOKEN is set' do
      provider.options.update(:token => nil)
      provider.context.env['FIREBASE_TOKEN'] = 'abc123'
      expect{ provider.check_auth }.not_to raise_error
    end
  end

  describe "#push_app" do
    before do
      expect(Dir).to receive(:chdir).with(deploy_dir).and_yield
    end

    it 'should include the project specified' do
      provider.options.update(:project => 'myapp-dev')
      expect(provider.context).to receive(:shell).with("firebase deploy --non-interactive --project myapp-dev --token 'abc123'")
      provider.push_app
    end

    it 'should include the message specified' do
      provider.options.update(:message => 'test message')
      expect(provider.context).to receive(:shell).with("firebase deploy --non-interactive --message 'test message' --token 'abc123'")
      provider.push_app
    end

    it 'should default to no project override' do
      expect(provider.context).to receive(:shell).with("firebase deploy --non-interactive --token 'abc123'")
      provider.push_app
    end

    context "with local-dir" do
      let(:deploy_dir) { "/tmp" }

      it 'should deploy from the specified dir' do
        provider.options.update(:local_dir => "/tmp")
        expect(provider.context).to receive(:shell).with("firebase deploy --non-interactive --token 'abc123'")
        provider.push_app
      end

    end
  end
end
