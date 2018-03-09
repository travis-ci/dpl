require 'spec_helper'
require 'chef/cookbook_loader'
require 'chef/cookbook_uploader'
require 'chef/cookbook_site_streaming_uploader'
require 'dpl/provider/chef_supermarket'

describe DPL::Provider::ChefSupermarket do
  subject :provider do
    described_class.new(
      DummyContext.new,
      app: 'example',
      cookbook_category: 'Others',
      user_id: 'user',
      client_key: '/tmp/example.pem'
    )
  end

  let(:cookbook_uploader) do
    double('cookbook_uploader', validate_cookbooks: true)
  end

  let(:http_resp) do
    double('http_resp', body: '{}', code: '201')
  end

  describe "#check_auth" do
    example do
      ::File.stub(:exist?).and_return(true)
      expect(File).to receive(:exist?)
      provider.check_auth
    end
  end

  describe "#check_app" do
    example do
      ::Chef::CookbookLoader.any_instance.stub(:[]).and_return nil
      expect(::Chef::CookbookUploader).to receive(:new).and_return(cookbook_uploader)
      provider.check_app
    end
  end

  describe "#push_app" do
    example do
      expect(::Chef::CookbookSiteStreamingUploader).to receive(:create_build_dir).and_return('/tmp/build_dir')
      expect(provider).to receive(:system).and_return(true)
      expect(::File).to receive(:open)
      expect(::Chef::CookbookSiteStreamingUploader).to receive(:post).and_return(http_resp)
      expect(::FileUtils).to receive(:rm_rf).with('/tmp/build_dir')
      provider.push_app
    end
  end
end
