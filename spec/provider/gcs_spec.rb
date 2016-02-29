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

  describe "#upload_path" do
    example "Without: :upload_dir" do
      filename = "testfile.file"

      expect(provider.upload_path(filename)).to eq("testfile.file")
    end

    example "With :upload_dir" do
      provider.options.update(:upload_dir => 'BUILD3')
      filename = "testfile.file"

      expect(provider.upload_path(filename)).to eq("BUILD3/testfile.file")
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

    example "Sends MIME type" do
      expect(Dir).to receive(:glob).and_yield(__FILE__)
      expect_any_instance_of(GStore::Client).to receive(:put_object).with(
        anything(),
        anything(),
        hash_including(:headers => {:"Content-Type" => 'application/x-ruby'})
      )
      provider.push_app
    end

    example "Sets Cache" do
      provider.options.update(:cache_control => "max-age=99999999")
      expect(Dir).to receive(:glob).and_yield(__FILE__)
      expect_any_instance_of(GStore::Client).to receive(:put_object).with(
        anything(),
        anything(),
        hash_including(:headers => hash_including("Cache-Control" => 'max-age=99999999'))
      )
      provider.push_app
    end

    example "Sets ACL" do
      provider.options.update(:acl => "public-read")
      expect(Dir).to receive(:glob).and_yield(__FILE__)
      expect_any_instance_of(GStore::Client).to receive(:put_object).with(
        anything(),
        anything(),
        hash_including(:headers => hash_including("x-goog-acl" => 'public-read'))
      )
      provider.push_app
    end

    example "when detect_encoding is set" do
      path = 'foo.js'
      provider.options.update(:detect_encoding => true)
      expect(Dir).to receive(:glob).and_yield(path)
      expect(provider).to receive(:`).at_least(1).times.with("file '#{path}'").and_return('gzip compressed')
      expect(File).to receive(:read).with(path).and_return("")
      expect_any_instance_of(GStore::Client).to receive(:put_object).with(
        anything(),
        anything(),
        hash_including(:headers => hash_including("Content-Encoding" => 'gzip'))
      )
      provider.push_app
    end

    example "With dot_match" do
      provider.options.update(:dot_match => true)

      expect(Dir).to receive(:glob).with('**/*', File::FNM_DOTMATCH)
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
