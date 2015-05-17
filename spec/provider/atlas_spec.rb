require 'securerandom'

require 'spec_helper'
require 'dpl/provider/atlas'

describe DPL::Provider::Atlas do
  before (:all) do
  end

  let(:context) { DummyContext.new }
  let(:options) { { token: SecureRandom.hex(16), include: 'bin/*', exclude: 'tmp/*' } }

  subject(:provider) { described_class.new(context, options) }

  describe '#check_auth' do
    specify 'without :app' do
      provider.options.delete(:app)
      expect { provider.check_auth }.to raise_error(DPL::Error)
    end

    specify 'with :app' do
      provider.options.update(app: 'dpl/testapp')
      expect { provider.check_auth }.to_not raise_error
    end
  end

  describe '#needs_key?' do
    it { expect(provider.needs_key?).to eq(false) }
  end

  describe '#push_app' do
    specify 'without :app' do
      provider.options.delete(:app)
      expect { provider.push_app }.to raise_error(DPL::Error)
    end

    specify 'with :app' do
      provider.options.update(app: 'dpl/testapp')
      expect { provider.push_app }.to_not raise_error
    end
  end
end
