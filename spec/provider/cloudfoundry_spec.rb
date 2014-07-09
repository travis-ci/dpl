require 'spec_helper'
require 'dpl/provider/cloud_foundry'

describe DPL::Provider::CloudFoundry do
  subject :provider do
    described_class.new(DummyContext.new, api: 'api.run.awesome.io', username: 'mallomar',
                        password: 'myreallyawesomepassword',
                        organization: 'myorg',
                        space: 'outer')
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with('wget http://go-cli.s3-website-us-east-1.amazonaws.com/releases/latest/cf-cli_amd64.deb -qO temp.deb && sudo dpkg -i temp.deb')
      expect(provider.context).to receive(:shell).with('rm temp.deb')
      expect(provider.context).to receive(:shell).with('cf api api.run.awesome.io')
      expect(provider.context).to receive(:shell).with('cf login --u mallomar --p myreallyawesomepassword --o myorg --s outer')
      provider.check_auth
    end
  end

  describe "#check_app" do
    example do
      expect{provider.check_app}.to raise_error('Application must have a manifest.yml for unattended deployment')
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with('cf push')
      expect(provider.context).to receive(:shell).with('cf logout')
      provider.push_app

    end
  end
end