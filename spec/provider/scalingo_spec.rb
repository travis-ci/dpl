require 'spec_helper'
require 'dpl/provider/scalingo'

describe DPL::Provider::Scalingo do
  subject :provider do
    described_class.new(DummyContext.new, :username => 'travis', :password => 'secret', :remote => 'scalingo', :branch => 'master')
  end

  describe "#install_deploy_dependencies" do
    example do
      expect(provider.context).to receive(:shell).with(
              'curl --silent --remote-name --location https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz && tar -zxf scalingo_latest_linux_amd64.tar.gz && mv scalingo_*_linux_amd64/scalingo . && rm scalingo_latest_linux_amd64.tar.gz && rm -r scalingo_*_linux_amd64'
      ).and_return(true)
      provider.install_deploy_dependencies
    end
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with(
        "echo -e \"travis\nsecret\" | SCALINGO_REGION=agora-fr1 timeout 60 ./scalingo login > /dev/null"
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'DISABLE_INTERACTIVE=true SCALINGO_REGION=agora-fr1 timeout 60 ./scalingo login > /dev/null'
      ).and_return(true)
      provider.check_auth
    end
  end

  describe "#setup_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        'SCALINGO_REGION=agora-fr1 timeout 60 ./scalingo keys-add dpl_tmp_key key_file > /dev/null'
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'DISABLE_INTERACTIVE=true SCALINGO_REGION=agora-fr1 timeout 60 ./scalingo login > /dev/null'
      ).and_return(true)
      provider.setup_key('key_file')
    end
  end

  describe "#remove_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        'SCALINGO_REGION=agora-fr1 timeout 60 ./scalingo keys-remove dpl_tmp_key > /dev/null'
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'DISABLE_INTERACTIVE=true SCALINGO_REGION=agora-fr1 timeout 60 ./scalingo login > /dev/null'
      ).and_return(true)
      provider.remove_key
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with(
              'curl --silent --remote-name --location https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz && tar -zxf scalingo_latest_linux_amd64.tar.gz && mv scalingo_*_linux_amd64/scalingo . && rm scalingo_latest_linux_amd64.tar.gz && rm -r scalingo_*_linux_amd64'
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'git push scalingo master --force'
      ).and_return(true)
      provider.push_app
    end
  end
end
