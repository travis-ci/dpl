require 'spec_helper'
require 'dpl/provider/azure_storage'

describe DPL::Provider::AzureStorage do
  subject :provider do
    described_class.new(DummyContext.new, :account_name => 'qwertyuiopasdfghjklz', :account_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz')
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:log).with("Logging in Account:qwertyuiopasdfghjklz")
      provider.check_auth
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "Without local_dir" do
      expect(Dir).to receive(:chdir).with(Dir.pwd)
      provider.push_app
    end

    example "With local_dir" do
      provider.options.update(:local_dir => 'BUILD')

      expect(Dir).to receive(:chdir).with('BUILD')
      provider.push_app
    end

    example "With dot_match" do
      provider.options.update(:dot_match => true)

      expect(Dir).to receive(:glob).with('**/*', File::FNM_DOTMATCH)
      provider.push_app
    end

  end

end
