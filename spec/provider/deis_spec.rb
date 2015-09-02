require 'spec_helper'
require 'dpl/provider/deis'

describe DPL::Provider::Deis do
  let(:options) do
    {
      :app => 'example',
      :key_name => 'key',
      :controller => 'https://deis.deisapps.com',
      :username => 'travis',
      :password => 'secret',
      :cli_version => '1.0'
    }
  end

  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  describe "#install_deploy_dependencies" do
    example do
      expect(provider.context).to receive(:shell).with(
        'curl -sSL http://deis.io/deis-cli/install.sh | sh -s 1.0'
      ).and_return(true)
      provider.install_deploy_dependencies
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(true)
    end
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with(
        './deis login https://deis.deisapps.com --username=travis --password=secret'
      ).and_return(true)
      provider.check_auth
    end
  end

  describe "#check_app" do
    example do
      expect(provider.context).to receive(:shell).with(
        './deis apps:info --app=example'
      ).and_return(true)
      provider.check_app
    end
  end

  describe "#setup_key" do
    let(:ssh_config_handle) { double 'ssh_config_handle' }
    let(:ssh_config) { File.join(Dir.home, '.ssh', 'config') }
    let(:identity_file) { File.join(Dir.pwd, 'key_file') }
    example do
      expect(provider.context).to receive(:shell).with(
        './deis keys:add key_file'
      ).and_return(true)
      provider.setup_key('key_file')
    end
  end

  describe "#setup_git_ssh" do
    example do
      expect(provider.context).to receive(:shell).with(
        './deis git:remote --app=example'
      ).and_return(true)
      provider.setup_git_ssh('foo', 'key_file')
    end
  end

  describe "#remove_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        './deis keys:remove key'
      ).and_return(true)
      provider.remove_key
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with(
        'git push deis HEAD:refs/heads/master -f'
      ).and_return(true)
      provider.push_app
    end
  end

  describe "#run" do
    example do
      expect(provider.context).to receive(:shell).with(
        'deis run -- shell command'
      ).and_return(true)
      provider.run('shell command')
    end
  end
end
