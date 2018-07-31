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
      expect(provider.context).to receive(:shell).with('test x$TRAVIS_OS_NAME = "xlinux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz')
      expect(provider.context).to receive(:shell).with('./cf api api.eu-gb.bluemix.net --skip-ssl-validation')
      expect(provider.context).to receive(:shell).with('./cf login -u Moonpie -p myexceptionallyaveragepassword -o myotherorg -s inner')
      provider.check_auth
    end
  end

end
