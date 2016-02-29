require 'spec_helper'
require 'dpl/provider/scalingo'

describe DPL::Provider::Scalingo do

  subject :provider do
    described_class.new(DummyContext.new, :username => 'travis', :password => 'secret', :remote => 'scalingo', :branch => 'master')
  end

  describe "#install_deploy_dependencies" do
    example do
      expect(provider.context).to receive(:shell).with(
              'curl -OL https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz && tar -zxvf scalingo_latest_linux_amd64.tar.gz && mv scalingo_*_linux_amd64/scalingo . && rm scalingo_latest_linux_amd64.tar.gz && rm -r scalingo_*_linux_amd64'
      ).and_return(true)
      provider.install_deploy_dependencies
    end
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with(
        "echo -e \"travis\nsecret\" | timeout 2 ./scalingo login 2> /dev/null > /dev/null"
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'DISABLE_INTERACTIVE=true ./scalingo login 2> /dev/null > /dev/null'
      ).and_return(true)
      provider.check_auth
    end
  end

  describe "#setup_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        './scalingo keys-add dpl_tmp_key key_file'
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'DISABLE_INTERACTIVE=true ./scalingo login 2> /dev/null > /dev/null'
      ).and_return(true)
      provider.setup_key('key_file')
    end
  end

  describe "#remove_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        './scalingo keys-remove dpl_tmp_key'
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        'DISABLE_INTERACTIVE=true ./scalingo login 2> /dev/null > /dev/null'
      ).and_return(true)
      provider.remove_key
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with(
        'git push scalingo master -f'
      ).and_return(true)
      provider.push_app
    end
  end

end
