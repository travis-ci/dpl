require 'spec_helper'
require 'dpl/provider/apm'

describe DPL::Provider::APM do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :api_key => 'foo')
  end

  describe '#check_auth' do
    example do
      expect(provider).to receive(:setup_auth)
      provider.check_auth
    end
  end

  describe '#install_atom' do
    example do
      expect(provider).to receive(:log).with('Downloading latest Atom release...')
      provider.install_atom
    end
  end

  describe '#check_atom_version' do
    example do
      expect(provider).to receive(:log).with('Using Atom version:')
      expect(provider.context).to receive(:shell).with('"$ATOM_SCRIPT_PATH" -v')
      provider.check_atom_version
    end
  end

  describe '#check_apm_version' do
    example do
      expect(provider).to receive(:log).with('Using APM version:')
      expect(provider.context).to receive(:shell).with('"$APM_SCRIPT_PATH" -v')
      provider.check_apm_version
    end
  end

  describe '#deploy_package' do
    example do
      expect(provider).to receive(:log).with('Deploying package:')
      expect(provider.context).to receive(:shell).with('"$APM_SCRIPT_PATH" publish --tag "$TRAVIS_TAG"')
      provider.deploy_package
    end
  end
end
