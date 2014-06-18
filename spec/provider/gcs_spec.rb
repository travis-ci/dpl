require 'spec_helper'
require 'dpl/provider/gcs'

describe DPL::Provider::GCS do

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :bucket => 'my-bucket')
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:log).with("Logging in with Access Key: ****************jklz")
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
  end

  describe '#client' do
    example do
      expect(GStore::Client).to receive(:new).with(
        :access_key => 'qwertyuiopasdfghjklz',
        :secret_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz'
      )
      provider.client
    end
  end
end
