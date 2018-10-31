require 'spec_helper'
require 'dpl/provider/cargo'

describe DPL::Provider::Cargo do
  context 'when token is not provided' do
    subject :provider do
      described_class.new(DummyContext.new, {})
    end

    describe "#check_auth" do
      example do
        expect { provider.check_auth }.to raise_error(DPL::Error, 'missing token')
      end
    end
  end

  context 'when token is provided' do
    subject :provider do
      described_class.new(DummyContext.new, token: "TEST_TOKEN")
    end

    describe "#check_auth" do
      example do
        expect { provider.check_auth }.not_to raise_error
      end
    end

    context 'when publish fails' do
      describe "#push_app" do
        example do
          expect(provider.context).to receive(:shell).with("cargo publish --token TEST_TOKEN") { false }
          expect { provider.push_app }.to raise_error('Publish failed')
        end
      end
    end

    context 'when publish succeeds' do
      describe "#push_app" do
        example do
          expect(provider.context).to receive(:shell).with("cargo publish --token TEST_TOKEN") { true }
          provider.push_app
        end
      end
    end
  end
end
