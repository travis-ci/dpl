require 'spec_helper'
require 'dpl/provider/cloud_foundry'

describe DPL::Provider::CloudFoundry do
  subject :provider do
    described_class.new(DummyContext.new, api: 'api.run.awesome.io', username: 'mallomar',
                        password: 'myreallyawesomepassword',
                        organization: 'myorg',
                        space: 'outer',
                        manifest: 'worker-manifest.yml',
                        skip_ssl_validation: true)
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with('wget \'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github\' -qO cf-linux-amd64.tgz && tar -zxvf cf-linux-amd64.tgz && rm cf-linux-amd64.tgz')
      expect(provider.context).to receive(:shell).with('./cf api api.run.awesome.io --skip-ssl-validation')
      expect(provider.context).to receive(:shell).with('./cf login -u mallomar -p myreallyawesomepassword -o myorg -s outer')
      provider.check_auth
    end
  end

  describe "#check_app" do
    context 'when the manifest file exists' do
      example do
        File.stub(:exists?).with('worker-manifest.yml').and_return(true)
        expect{provider.check_app}.not_to raise_error
      end
    end

    context 'when the manifest file exists' do
      example do
        File.stub(:exists?).with('worker-manifest.yml').and_return(false)
        expect{provider.check_app}.to raise_error('Application must have a manifest.yml for unattended deployment')
      end
    end

    context 'when zero-downtime is specified without an app name' do
      example do
        provider.options.update(:zero_downtime => true)
        File.stub(:exists?).with('worker-manifest.yml').and_return(true)
        expect{provider.check_app}.to raise_error('Application name must be specified for zero-downtime deployment')
      end
    end

    context 'when zero-downtime is specified with an app name' do
      example do
        provider.options.update(:app_name => 'foo', :zero_downtime => true)
        File.stub(:exists?).with('worker-manifest.yml').and_return(true)
        expect{provider.check_app}.not_to raise_error
      end
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "With manifest" do
      expect(provider.context).to receive(:shell).with('./cf push -f worker-manifest.yml')
      expect(provider.context).to receive(:shell).with('./cf logout')
      provider.push_app
    end

    example "Without manifest" do
      provider.options.update(:manifest => nil)
      expect(provider.context).to receive(:shell).with('./cf push')
      expect(provider.context).to receive(:shell).with('./cf logout')
      provider.push_app
    end

    example "Zero-downtime" do
      provider.options.update(:app_name => 'foo', :zero_downtime => true)
      expect(provider.context).to receive(:shell).with('./cf install-plugin https://github.com/contraband/autopilot/releases/download/0.0.3/autopilot-linux')
      expect(provider.context).to receive(:shell).with('./cf zero-downtime-push foo -f worker-manifest.yml')
      expect(provider.context).to receive(:shell).with('./cf logout')
      provider.push_app
    end
  end
end
