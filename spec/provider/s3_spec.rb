require 'spec_helper'
require 'dpl/provider/s3'

describe DPL::Provider::S3 do

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :bucket => 'my-bucket')
  end

  describe '#s3_options' do
    context 'without region' do
      example do
        options = provider.s3_options
        expect(options[:region]).to eq('us-east-1')
      end
    end

    context 'with region' do
      example do
        region = 'us-west-1'
        provider.options.update(:region => region)
        options = provider.s3_options
        expect(options[:region]).to eq(region)
      end
    end
  end
end

describe DPL::Provider::S3 do

  access_key_id = 'qwertyuiopasdfghjklz'
  secret_access_key = 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz'
  region = 'us-east-1'
  bucket = 'my-bucket'

  client_options = {
    stub_responses: true,
    region: region,
    credentials: Aws::Credentials.new(access_key_id, secret_access_key)
  }

  subject :provider do
    described_class.new(DummyContext.new, {
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      bucket: bucket
    })
  end

  before :each do
    allow(provider).to receive(:s3_options).and_return(client_options)
    allow_any_instance_of(::Aws::S3::Object).to receive(:upload_file).and_return(true)
    allow(provider).to receive(:log).with(anything).and_return(true)
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:log).with("Logging in with Access Key: ****************jklz")
      provider.check_auth
    end
  end

  describe "#upload_path" do
    example "Without :upload_dir"do
      filename = "testfile.file"

      expect(provider.upload_path(filename)).to eq("testfile.file")
    end

    example "With :upload_dir" do
      provider.options.update(:upload_dir => 'BUILD3')
      filename = "testfile.file"

      expect(provider.upload_path(filename)).to eq("BUILD3/testfile.file")
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "With local_dir" do
      someDir = "/some/dir/"
      provider.options.update(:local_dir => someDir)
      allow(Dir).to receive(:chdir).with(someDir).and_return(true)
      allow(Dir).to receive(:chdir).with(Dir.pwd).and_return(true)
      expect(Dir).to receive(:glob).with("**/*").and_return([__FILE__])
      provider.push_app
    end

    example "Sends MIME type" do
      expect(Dir).to receive(:glob).and_return([__FILE__])
      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(anything(), hash_including(:content_type => 'application/x-ruby'))
      provider.push_app
    end

    example "Sets Cache and Expiration" do
      provider.options.update(:cache_control => "max-age=99999999", :expires => "2012-12-21 00:00:00 -0000")
      expect(Dir).to receive(:glob).and_return([__FILE__])
      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(anything(), hash_including(:cache_control => 'max-age=99999999', :expires => '2012-12-21 00:00:00 -0000'))
      provider.push_app
    end

    example "Sets different Cache and Expiration" do
      option_list = []
      provider.options.update(:cache_control => ["max-age=99999999", "no-cache" => ["foo.html", "bar.txt"], "max-age=9999" => "*.txt"], :expires => ["2012-12-21 00:00:00 -0000", "1970-01-01 00:00:00 -0000" => "*.html"])
      expect(Dir).to receive(:glob).and_return(%w(foo.html bar.txt baz.js))
      allow_any_instance_of(Aws::S3::Object).to receive(:upload_file) do |obj, _data, options|
        option_list << { key: obj.key, options: options }
      end
      provider.push_app
      expect(option_list).to match_array([
        { key: "foo.html", options: hash_including(:cache_control => "no-cache", :expires => "1970-01-01 00:00:00 -0000") },
        { key: "bar.txt", options: hash_including(:cache_control => "max-age=9999", :expires => "2012-12-21 00:00:00 -0000") },
        { key: "baz.js", options: hash_including(:cache_control => "max-age=99999999", :expires => "2012-12-21 00:00:00 -0000") },
      ])
    end

    example "Sets ACL" do
      provider.options.update(:acl => "public_read")
      expect(Dir).to receive(:glob).and_return([__FILE__])
      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(anything(), hash_including(:acl => "public-read"))
      provider.push_app
    end

    example "Sets Storage Class" do
      provider.options.update(:storage_class => "STANDARD_AI")
      expect(Dir).to receive(:glob).and_return([__FILE__])
      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(anything(), hash_including(:storage_class => "STANDARD_AI"))
      provider.push_app
    end

    example "Sets SSE" do
      provider.options.update(:server_side_encryption => true)
      expect(Dir).to receive(:glob).and_return([__FILE__])
      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(anything(), hash_including(:server_side_encryption => "AES256"))
      provider.push_app
    end

    example "Sets Website Index Document" do
      provider.options.update(:index_document_suffix => "test/index.html")
      expect(Dir).to receive(:glob).and_return([__FILE__])
      expect_any_instance_of(Aws::S3::BucketWebsite).to receive(:put).with(:website_configuration => { :index_document => { :suffix => "test/index.html" } })
      provider.push_app
    end

    example "when detect_encoding is set" do
      path = 'foo.js'
      provider.options.update(:detect_encoding => true)
      expect(Dir).to receive(:glob).and_return([path])
      expect(provider).to receive(:`).at_least(1).times.with("file '#{path}'").and_return('gzip compressed')
      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(anything(), hash_including(:content_encoding => 'gzip'))
      provider.push_app
    end

    example "when dot_match is set" do
      provider.options.update(:dot_match => true)
      expect(Dir).to receive(:glob).with("**/*", File::FNM_DOTMATCH).and_return([__FILE__])
      provider.push_app
    end

    example "when max_threads is set" do
      provider.options.update(:max_threads => 10)
      expect(Dir).to receive(:glob).with("**/*").and_return([__FILE__])
      expect(provider).to receive(:log).with("Beginning upload of 1 files with 10 threads.")
      provider.push_app
    end

    example "when max_threads is too large" do
      provider.options.update(:max_threads => 100)
      expect(Dir).to receive(:glob).with("**/*").and_return([__FILE__])
      expect(provider).to receive(:log).with("Beginning upload of 1 files with 15 threads.")
      expect(provider).to receive(:log).with("Desired thread count 100 is too large. Using 15.")
      provider.push_app
    end
  end
end
