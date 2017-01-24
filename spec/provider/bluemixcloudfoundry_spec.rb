require 'spec_helper'
require 'dpl/provider/bluemix_cloud_foundry'

describe DPL::Provider::BluemixCloudFoundry do
  subject :provider do
    described_class.new(DummyContext.new, region: 'eu-gb', username: 'Moonpie',
                        password: 'myexceptionallyaveragepassword',
                        organization: 'myotherorg',
                        space: 'inner',
                        manifest: 'worker-manifest.yml',
                        skip_ssl_validation: true)
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with('wget \'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github\' -qO cf-linux-amd64.tgz && tar -zxvf cf-linux-amd64.tgz && rm cf-linux-amd64.tgz')
      expect(provider.context).to receive(:shell).with('./cf api api.eu-gb.bluemix.net --skip-ssl-validation')
      expect(provider.context).to receive(:shell).with('./cf login -u Moonpie -p myexceptionallyaveragepassword -o myotherorg -s inner')
      provider.check_auth
    end
  end

end
