require 'spec_helper'
require 'dpl/provider/qingstor'

describe DPL::Provider::QingStor do

  access_key_id = 'XXXXXXXXXXXXXXXXXXXX'
  secret_access_key = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  bucket = 'test-bucket'

  subject :provider do
    described_class.new(DummyContext.new, {
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      bucket: bucket
    })
  end

  describe "#check_auth" do
    example do
      provider.check_auth
    end
  end

  describe "#check_app" do
    example do
      provider.check_app
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

    example "When dot_match is set" do
      provider.options.update(:dot_match => true)
      expect(Dir).to receive(:glob).with("**/*", File::FNM_DOTMATCH)
      provider.push_app
    end
  end
end
