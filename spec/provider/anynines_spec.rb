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
      expect(provider.context).to receive(:shell).with('wget http://go-cli.s3-website-us-east-1.amazonaws.com/releases/latest/cf-cli_amd64.deb -qO temp.deb && sudo dpkg -i temp.deb')
      expect(provider.context).to receive(:shell).with('rm temp.deb')
      expect(provider.context).to receive(:shell).with('cf api https://api.de.a9s.eu')
      expect(provider.context).to receive(:shell).with('cf login --u mallomar --p myreallyawesomepassword --o myorg --s outer')
      provider.check_auth
    end
  end
end
