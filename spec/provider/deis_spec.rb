require 'spec_helper'
require 'dpl/provider/deis'

describe DPL::Provider::Deis do
  let(:options) do
    {
      :app => 'example',
      :key_name => 'key',
      :controller => 'deis.deisapps.com',
      :username => 'travis',
      :password => 'secret'
    }
  end

  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  describe "#install_deploy_dependencies" do
    example 'without version specified' do
      expect(provider.class).to receive(:pip).with('deis', 'deis', nil)
      provider.install_deploy_dependencies
    end

    example 'with version specified' do
      options[:cli_version] = '1.0'
      expect(provider.class).to receive(:pip).with('deis', 'deis', '1.0')
      provider.install_deploy_dependencies
    end
  end

  describe '#controller_url' do
    example 'no protocol specified' do
      expect(provider.send(:controller_url)).to eq 'http://deis.deisapps.com'
    end

    example 'protocol specified' do
      options[:controller] = 'https://deis.deisapps.com'
      expect(provider.send(:controller_url)).to eq 'https://deis.deisapps.com'
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
        'deis login http://deis.deisapps.com --username=travis --password=secret'
      ).and_return(true)
      provider.check_auth
    end
  end

  describe "#check_app" do
    example do
      expect(provider.context).to receive(:shell).with(
        'deis apps:info --app=example'
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
        'deis keys:add key_file'
      ).and_return(true)
      provider.setup_key('key_file')
    end
  end

  describe "#setup_git_ssh" do
    let(:ssh_config_handle) { double 'ssh_config_handle' }
    let(:ssh_config) { File.join(Dir.home, '.ssh', 'config') }
    let(:identity_file) { File.join(Dir.pwd, 'key_file') }
    let(:git_ssh) { File.join(Dir.pwd, 'foo') }
    after { FileUtils.rm provider.context.env.delete('GIT_SSH') }

    example do
      expect(File).to receive(:open).with(git_ssh, 'w').and_call_original
      expect(File).to receive(:open).with(ssh_config, 'a')
        .and_yield(ssh_config_handle)

      expect(ssh_config_handle).to receive(:write).with(
        "\nHost deis-repo\n  Hostname deis.deisapps.com\n  Port 2222\n" \
        "  User git\n  IdentityFile #{identity_file}\n"
      )
      expect(provider.context).to receive(:shell).with(
        'git remote add deis ssh://git@deis.deisapps.com:2222/example.git'
      )
      provider.setup_git_ssh('foo', 'key_file')
    end
  end

  describe "#remove_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        'deis keys:remove key'
      ).and_return(true)
      provider.remove_key
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with(
        'git push deis-repo:example.git HEAD:refs/heads/master -f'
      ).and_return(true)
      provider.push_app
    end
  end

  describe "#run" do
    example do
      expect(provider.context).to receive(:shell).with(
        'deis apps:run shell command'
      ).and_return(true)
      provider.run('shell command')
    end
  end
end
