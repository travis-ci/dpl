require 'securerandom'

require 'spec_helper'
require 'dpl/provider/atlas'

describe DPL::Provider::Atlas do
  before :all do
    @origwd = Dir.pwd
    @tmpdir = Dir.mktmpdir
    ENV['HOME'] = @tmpdir
    Dir.chdir(@tmpdir)
  end

  after :all do
    FileUtils.rm_rf(@tmpdir) if @tmpdir
    Dir.chdir(@origwd) if @origwd
  end

  let(:context) { DummyContext.new }
  let(:options) { { token: SecureRandom.hex(16), include: 'bin/*', exclude: 'tmp/*' } }

  subject(:provider) { described_class.new(context, options) }

  describe '#check_auth' do
    specify 'without ATLAS_TOKEN' do
      provider.options.delete(:token)
      expect { provider.check_auth }.to raise_error(DPL::Error)
    end

    specify 'with ATLAS_TOKEN' do
      provider.options.update(token: SecureRandom.hex(16))
      expect { provider.check_auth }.to_not raise_error
    end
  end

  describe '#needs_key?' do
    it { expect(provider.needs_key?).to eq(false) }
  end

  describe '#deploy' do
    specify 'without :app aborts' do
      provider.options.delete(:app)
      expect { provider.deploy }.to raise_error(DPL::Error)
    end

    specify 'with :app does not abort' do
      provider.options.update(app: 'dpl/testapp')
      expect { provider.deploy }.to_not raise_error
    end
  end

  describe 'building atlas-upload args' do
    context 'when full args are provided' do
      let(:options) { { args: '-whatever' } }

      it 'returns full args directly' do
        expect(provider.send(:atlas_upload_args)).to eql('-whatever')
      end
    end

    context 'when no arg keys are provided' do
      let(:options) { {} }

      it 'returns empty args' do
        expect(provider.send(:atlas_upload_args)).to eql('')
      end
    end

    [
      {
        options: { wat: true, debug: true },
        args: '-debug'
      },
      {
        options: { vcs: nil },
        args: '-vcs'
      },
      {
        options: { include: ['build/*', 'bin/*'], exclude: '*.log' },
        args: '-exclude="*.log" -include="build/*" -include="bin/*"'
      },
      {
        options: {
          include: 'bin/*',
          exclude: ['*.log', '*.out'],
          metadata: ['foo=bar', 'whatever=else']
        },
        args: '-exclude="*.log" -exclude="*.out" -include="bin/*" -metadata="foo=bar" -metadata="whatever=else"'
      }
    ].each_with_index do |example, i|
      context "with options #{example[:options].inspect}" do
        let(:options) { example[:options] }
        it { expect(provider.send(:atlas_upload_args)).to eql(example[:args]) }
      end
    end
  end
end
