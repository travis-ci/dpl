require 'spec_helper'
require 'dpl/provider/bintray'

describe DPL::Provider::Bintray do

  subject :provider do
    described_class.new(DummyContext.new,
                        :user => 'user',
                        :key => 'key',
                        :file => 'file',
                        :dry_run => 'true')
  end

  subject :provider_with_passphrase do
    described_class.new(DummyContext.new,
                        :user => 'user',
                        :key => 'key',
                        :file => 'file',
                        :dry_run => 'true',
                        :passphrase => 'passphrase')
  end

  describe "package_exists?" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]

      init_provider(provider)
      expect(provider.package_exists_path).to eq("/packages/#{subject}/#{repo}/#{package_name}")
    end
  end

  describe "version_exists?" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]
      version_name = descriptor["version"]["name"]

      init_provider(provider)
      expect(provider.version_exists_path).to eq("/packages/#{subject}/#{repo}/#{package_name}/versions/#{version_name}")
    end
  end

  describe "create_package" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      subject = package["subject"]
      repo = package["repo"]

      init_provider(provider)
      request_details = provider.create_package
      expect(request_details.path).to eq("/packages/#{subject}/#{repo}")

      body = {
          'name' => package["name"],
          'desc' => package["desc"],
          'licenses' => package["licenses"],
          'labels' => package["labels"],
          'vcs_url' => package["vcs_url"],
          'website_url' => package["website_url"],
          'issue_tracker_url' => package["issue_tracker_url"],
          'public_download_numbers' => package["public_download_numbers"],
          'public_stats' => package["public_stats"]
      }
      expect(request_details.body).to eq(body)
    end
  end

  describe "create_version" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]

      init_provider(provider)
      request_details = provider.create_version
      expect(request_details.path).to eq("/packages/#{subject}/#{repo}/#{package_name}/versions")

      version = descriptor["version"]
      body = {
          'name' => version["name"],
          'desc' => version["desc"],
          'released' => version["released"],
          'vcs_tag' => version["vcs_tag"],
          'attributes' => version["attributes"]
      }
      expect(request_details.body).to eq(body)
    end
  end

  describe "add_package_attributes" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]

      init_provider(provider)
      request_details = provider.add_package_attributes
      expect(request_details.path).to eq("/packages/#{subject}/#{repo}/#{package_name}/attributes")

      body = package["attributes"]
      expect(request_details.body).to eq(body)
    end
  end

  describe "add_version_attributes" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]
      version_name = descriptor["version"]["name"]

      init_provider(provider)
      request_details = provider.add_version_attributes
      expect(request_details.path).to eq("/packages/#{subject}/#{repo}/#{package_name}/versions/#{version_name}/attributes")

      descriptor = JSON.parse(descriptor_content)
      version = descriptor["version"]
      body = version["attributes"]
      expect(request_details.body).to eq(body)
    end
  end

  describe "publish_version" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]
      version_name = descriptor["version"]["name"]

      init_provider(provider)
      request_details = provider.publish_version
      expect(request_details.path).to eq("/content/#{subject}/#{repo}/#{package_name}/#{version_name}/publish")
    end
  end

  describe "gpg_sign_version_without_passphrase" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]
      version_name = descriptor["version"]["name"]

      init_provider(provider)
      request_details = provider.gpg_sign_version
      expect(request_details.path).to eq("/gpg/#{subject}/#{repo}/#{package_name}/versions/#{version_name}")
      expect(request_details.body).to eq(nil)
    end
  end

  describe "gpg_sign_version_with_passphrase" do
    example do
      descriptor = JSON.parse(descriptor_content)
      package = descriptor["package"]
      package_name = package["name"]
      subject = package["subject"]
      repo = package["repo"]
      version_name = descriptor["version"]["name"]

      init_provider(provider_with_passphrase)
      request_details = provider_with_passphrase.gpg_sign_version
      expect(request_details.path).to eq("/gpg/#{subject}/#{repo}/#{package_name}/versions/#{version_name}")

      body = {
          'passphrase' => 'passphrase'
      }
      expect(request_details.body).to eq(body)
    end
  end

  describe "upload_files" do
    example do
      init_provider(provider)
      files_to_upload = Hash.new()
      matrix_params = {
          'p1' => 'a',
          'p2' => 'b'
      }

      provider.add_if_matches(files_to_upload, 'build/files/a.gem', 'build/files/(.*.gem)', 'exclude', 'a/b/$1', nil)
      provider.add_if_matches(files_to_upload, 'build/files/b.gem', 'build/files/(.*.gem)', nil, 'a/b/$1', matrix_params)
      provider.add_if_matches(files_to_upload, 'build/files/c.gem', 'build/files/(.*.gem)', '.*files.*', 'a/b/$1', nil)
      provider.add_if_matches(files_to_upload, 'build/files/c.txt', 'build/files/(.*.gem)', 'exclude', 'a/b/$1', nil)

      expect(files_to_upload["build/files/a.gem"]).not_to eq(nil)
      expect(files_to_upload["build/files/a.gem"].upload_path).to eq('a/b/a.gem')
      expect(files_to_upload["build/files/a.gem"].matrix_params).to eq(nil)

      expect(files_to_upload["build/files/b.gem"]).not_to eq(nil)
      expect(files_to_upload["build/files/b.gem"].upload_path).to eq('a/b/b.gem')
      expect(files_to_upload["build/files/b.gem"].matrix_params).to eq(matrix_params)

      expect(files_to_upload["build/files/c.gem"]).to eq(nil)
      expect(files_to_upload["build/files/c.txt"]).to eq(nil)
    end
  end

  def init_provider(bintray)
    bintray.descriptor=descriptor_content
    bintray.test_mode = true
  end

  def descriptor_content
    return """ {
          \"package\": {
            \"name\": \"auto-upload\",
            \"repo\": \"myRepo\",
            \"subject\": \"myBintrayUser\",
            \"desc\": \"I was pushed completely automatically\",
            \"website_url\": \"www.jfrog.com\",
            \"issue_tracker_url\": \"https://github.com/bintray/bintray-client-java/issues\",
            \"vcs_url\": \"https://github.com/bintray/bintray-client-java.git\",
            \"github_use_tag_release_notes\": true,
            \"github_release_notes_file\": \"RELEASE.txt\",
            \"licenses\": [\"MIT\"],
            \"labels\": [\"cool\", \"awesome\", \"gorilla\"],
            \"public_download_numbers\": false,
            \"public_stats\": false,
            \"attributes\": [{\"name\": \"att1\", \"values\" : [\"val1\"], \"type\": \"string\"},
                       {\"name\": \"att2\", \"values\" : [1, 2.2, 4], \"type\": \"number\"},
                       {\"name\": \"att5\", \"values\" : [\"2014-12-28T19:43:37+0100\"], \"type\": \"date\"}]
          },
          \"version\": {
            \"name\": \"0.5\",
            \"desc\": \"This is a version\",
            \"released\": \"2015-01-04\",
            \"vcs_tag\": \"0.5\",
            \"attributes\": [{\"name\": \"VerAtt1\", \"values\" : [\"VerVal1\"], \"type\": \"string\"},
                       {\"name\": \"VerAtt2\", \"values\" : [1, 3.3, 5], \"type\": \"number\"},
                     {\"name\": \"VerAtt3\", \"values\" : [\"2015-01-01T19:43:37+0100\"], \"type\": \"date\"}],
            \"gpgSign\": true
          },
          \"files\":
            [
            {\"includePattern\": \"build/bin/(*.gem)\", \"excludePattern\": \".*/do-not-deploy/.*\", \"uploadPattern\": \"gems/$1\"},
            {\"includePattern\": \"build/docs/(.*)\", \"uploadPattern\": \"docs/$1\"}
            ],
          \"publish\": true
        }
        """
  end
end