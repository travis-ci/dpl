require 'spec_helper'
require 'dpl/provider/azure_webapps'


describe DPL::Provider::AzureWebApps do
  subject :provider do
    described_class.new(DummyContext.new,
                        :username => 'myUsername',
                        :password => 'myPassword',
                        :site => 'myWebsite',
                        :slot => 'mySlot')
  end

  subject :provider_without_slot do
    described_class.new(DummyContext.new,
                        :username => 'myUsername',
                        :password => 'myPassword',
                        :site => 'myWebsite')
  end


  describe "#git_target" do
    example "With slot" do
      expect(provider.git_target).to eq('https://myUsername:myPassword@mySlot.scm.azurewebsites.net:443/myWebsite.git')
    end

    example "Without slot" do
      expect(provider_without_slot.git_target).to eq('https://myUsername:myPassword@myWebsite.scm.azurewebsites.net:443/myWebsite.git')
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#check_auth" do
    example "Without credentials" do
      provider.options.update(:username => nil)
      provider.options.update(:password => nil)
      provider.options.update(:site => nil)
      expect{provider.check_auth}.to raise_error(DPL::Error, 'missing Azure Git Deployment username')
    end

    example "Without username" do
      provider.options.update(:username => nil)
      expect{provider.check_auth}.to raise_error(DPL::Error, 'missing Azure Git Deployment username')
    end

    example "Without password" do
      provider.options.update(:password => nil)
      expect{provider.check_auth}.to raise_error(DPL::Error, 'missing Azure Git Deployment password')
    end

    example "Without WebApp name" do
      provider.options.update(:site => nil)
      expect{provider.check_auth}.to raise_error(DPL::Error, 'missing Azure Web App name')
    end
  end

  describe "push_app" do
    example "skip cleanup" do
      provider.options.update(:skip_cleanup => true)
      provider.options.update(:verbose => false)
      expect(provider.context).to receive(:shell).with('git checkout HEAD')
      expect(provider.context).to receive(:shell).with('git add . --all --force')
      expect(provider.context).to receive(:shell).with('git commit -m "Skip Cleanup Commit"')
      expect(provider.context).to receive(:shell).with('git push --force --quiet https://myUsername:myPassword@mySlot.scm.azurewebsites.net:443/myWebsite.git HEAD:refs/heads/master > /dev/null 2>&1')
      provider.push_app
    end

    example "Dont skip cleanup" do
      provider.options.update(:skip_cleanup => false)
      provider.options.update(:verbose => false)
      expect(provider.context).to receive(:shell).with('git push --force --quiet https://myUsername:myPassword@mySlot.scm.azurewebsites.net:443/myWebsite.git HEAD:refs/heads/master > /dev/null 2>&1')
      provider.push_app
    end

    example "Verbose" do
      provider.options.update(:skip_cleanup => false)
      provider.options.update(:verbose => true)
      expect(provider.context).to receive(:shell).with('git push --force --quiet https://myUsername:myPassword@mySlot.scm.azurewebsites.net:443/myWebsite.git HEAD:refs/heads/master')
      provider.push_app
    end

    example "Not verbose" do
      provider.options.update(:skip_cleanup => false)
      provider.options.update(:verbose => false)
      expect(provider.context).to receive(:shell).with('git push --force --quiet https://myUsername:myPassword@mySlot.scm.azurewebsites.net:443/myWebsite.git HEAD:refs/heads/master > /dev/null 2>&1')
      provider.push_app
    end 
  end

end