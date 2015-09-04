require 'spec_helper'
require 'dpl/provider/anynines'

describe DPL::Provider::Anynines do
  subject :provider do
    described_class.new(DummyContext.new, username: 'mallomar',
                        password: 'myreallyawesomepassword',
                        organization: 'myorg',
                        space: 'outer')
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with('wget http://go-cli.s3-website-us-east-1.amazonaws.com/releases/latest/cf-linux-amd64.tgz -qO cf-linux-amd64.tgz && tar -zxvf cf-linux-amd64.tgz && rm cf-linux-amd64.tgz')
      expect(provider.context).to receive(:shell).with('cf api https://api.de.a9s.eu')
      expect(provider.context).to receive(:shell).with('cf login --u mallomar --p myreallyawesomepassword --o myorg --s outer')
      provider.check_auth
    end
  end
end
