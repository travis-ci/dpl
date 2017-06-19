require 'spec_helper'
require 'dpl/provider/convox'

describe DPL::Provider::Convox do
  subject :provider do
    described_class.new(DummyContext.new, :rack => 'dummy-rack', :app => 'dummy-app', :console_key => 'dummy-key')
  end

  describe "#install_deploy_dependencies" do
    it 'should fire up docker daemon, install Convox CLI and cleanup' do
      expect(provider.context).to receive(:shell).with(
        'sudo start-docker-daemon && curl -O https://bin.equinox.io/c/jewmwFCp7w9/convox-stable-linux-amd64.tgz && sudo tar zxvf convox-stable-linux-amd64.tgz -C /usr/local/bin && rm convox-stable-linux-amd64.tgz'
      ).and_return(true)
      provider.install_deploy_dependencies
    end
  end

  describe "#check_auth" do
    it 'should require a console_key if no console_key is set' do
      provider.options.update(:console_key => nil)
      expect{ provider.check_auth }.to raise_error("Must supply console_key option")
    end

    it 'should default to console.convox.com if no console is set' do
      provider.options.update(:console_host => nil)
      expect(provider.context).to receive(:shell).with(
        "convox login console.convox.com --password dummy-key"
      ).and_return(true)
      provider.check_auth
    end
  end

  describe "#push_app" do
    it 'should include description if specified' do
      provider.options.update(:description => 'something')
      expect(provider.context).to receive(:shell).with(
        "convox deploy --app dummy-app --rack dummy-rack --description something"
      ).and_return(true)
      provider.push_app
    end

    it 'should copy build to another app in the same rack' do
      provider.options.update(:copy_to_app => 'another-app')
      expect(provider.context).to receive(:shell).with(
        "convox deploy --app dummy-app --rack dummy-rack"
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        "convox builds export $(convox builds --app dummy-app --rack dummy-rack | awk 'NR==2 {print $1}') --app dummy-app --rack dummy-rack | convox builds import --app another-app --rack dummy-rack"
      ).and_return(true)
      provider.push_app
    end

    it 'should copy build to another app in another rack' do
      provider.options.update(:copy_to_app => 'another-app')
      provider.options.update(:copy_to_rack => 'another-rack')
      expect(provider.context).to receive(:shell).with(
        "convox deploy --app dummy-app --rack dummy-rack"
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        "convox builds export $(convox builds --app dummy-app --rack dummy-rack | awk 'NR==2 {print $1}') --app dummy-app --rack dummy-rack | convox builds import --app another-app --rack another-rack"
      ).and_return(true)
      provider.push_app
    end

  end
end
