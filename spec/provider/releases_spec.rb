require 'spec_helper'
require 'dpl/provider/releases'
require 'octokit'

describe DPL::Provider::Releases do
  subject :provider do
    described_class.new(DummyContext.new, :api_key => '0123445789qwertyuiop0123445789qwertyuiop', :file => 'blah.txt')
  end

  describe "#travis_tag" do
    example "When $TRAVIS_TAG is nil" do
      ENV['TRAVIS_TAG'] = nil

      expect(provider.travis_tag).to eq(nil)
    end

    example "When $TRAVIS_TAG if set but empty" do
      ENV['TRAVIS_TAG'] = nil

      expect(provider.travis_tag).to eq(nil)
    end

    example "When $TRAVIS_TAG if set" do
      ENV['TRAVIS_TAG'] = "foo"

      expect(provider.travis_tag).to eq("foo")
    end
  end

  describe "#api" do
    example "With API key" do
      api = double(:api)
      expect(::Octokit::Client).to receive(:new).with(:access_token => '0123445789qwertyuiop0123445789qwertyuiop').and_return(api)
      expect(provider.api).to eq(api)
    end

    example "With username and password" do
      api = double(:api)
      provider.options.update(:user => 'foo')
      provider.options.update(:password => 'bar')

      expect(::Octokit::Client).to receive(:new).with(:login => 'foo', :password  => 'bar').and_return(api)
      expect(provider.api).to eq(api)
    end
  end

  describe "#releases" do
    example "With ENV Slug" do
      allow(provider).to receive(:slug).and_return("foo/bar")

      expect(provider.api).to receive(:releases).with("foo/bar")
      provider.releases
    end

    example "With repo option" do
      provider.options.update(:repo => 'bar/foo')

      expect(provider.api).to receive(:releases).with('bar/foo')
      provider.releases
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#check_app" do
    example "Without $TRAVIS_TAG" do
      allow(provider).to receive(:travis_tag).and_return(nil)
      allow(provider).to receive(:slug).and_return("foo/bar")
      allow(provider).to receive(:get_tag).and_return("foo")

      expect(provider.context).to receive(:shell).with("git fetch --tags")
      expect(provider).to receive(:log).with("Deploying to repo: foo/bar")
      expect(provider).to receive(:log).with("Current tag is: foo")

      provider.check_app
    end

    example "With $TRAVIS_TAG" do
      allow(provider).to receive(:travis_tag).and_return("bar")
      allow(provider).to receive(:slug).and_return("foo/bar")

      expect(provider.context).not_to receive(:shell).with("git fetch --tags")
      expect(provider).to receive(:log).with("Deploying to repo: foo/bar")
      expect(provider).to receive(:log).with("Current tag is: bar")
      
      provider.check_app
    end
  end

  describe "#get_tag" do
    example "Without $TRAVIS_TAG" do
      allow(provider).to receive(:travis_tag).and_return(nil)
      allow(provider).to receive(:`).and_return("bar")

      expect(provider.get_tag).to eq("bar")
    end

    example "With $TRAVIS_TAG" do
      allow(provider).to receive(:travis_tag).and_return("foo")

      expect(provider.get_tag).to eq("foo")
    end
  end

  describe "#check_auth" do
    example "With proper permissions" do
      allow_message_expectations_on_nil
      allow(provider).to receive(:user)
      allow(provider).to receive(:setup_auth)
      expect(provider.api).to receive(:scopes).and_return(["public_repo"])
      expect(provider.user).to receive(:name).and_return("foo")
      expect(provider).to receive(:log).with("Logged in as foo")
      provider.check_auth
    end

    example "With improper permissions" do
      allow_message_expectations_on_nil
      allow(provider).to receive(:user)
      allow(provider).to receive(:setup_auth)
      expect(provider.api).to receive(:scopes).exactly(2).times.and_return([])
      expect { provider.check_auth }.to raise_error(DPL::Error)
    end
  end

  describe "#push_app" do
    example "When Release Exists but has no Files" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["test/foo.bar", "bar.txt"])

      allow(provider).to receive(:releases).and_return([""])
      allow(provider).to receive(:get_tag).and_return("v0.0.0")

      provider.releases.map do |release|
        allow(release).to receive(:tag_name).and_return("v0.0.0")
        allow(release).to receive(:rels).and_return({:self => nil})
        allow(release.rels[:self]).to receive(:href)
      end

      allow(provider.api).to receive(:release)
      allow(provider.api.release).to receive(:rels).and_return({:assets => nil})
      allow(provider.api.release.rels[:assets]).to receive(:get).and_return({:data => [""]})
      allow(provider.api.release.rels[:assets].get).to receive(:data).and_return([])

      expect(provider.api).to receive(:upload_asset).with(anything, "test/foo.bar", {:name=>"foo.bar", :content_type=>"application/octet-stream"})
      expect(provider.api).to receive(:upload_asset).with(anything, "bar.txt", {:name=>"bar.txt", :content_type=>"text/plain"})

      provider.push_app
    end

    example "When Release Exists and has Files" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["test/foo.bar", "bar.txt"])

      allow(provider).to receive(:releases).and_return([""])
      allow(provider).to receive(:get_tag).and_return("v0.0.0")

      provider.releases.map do |release|
        allow(release).to receive(:tag_name).and_return("v0.0.0")
        allow(release).to receive(:rels).and_return({:self => nil})
        allow(release.rels[:self]).to receive(:href)
      end

      allow(provider.api).to receive(:release)
      allow(provider.api.release).to receive(:rels).and_return({:assets => nil})
      allow(provider.api.release.rels[:assets]).to receive(:get).and_return({:data => [""]})
      allow(provider.api.release.rels[:assets].get).to receive(:data).and_return([double(:name => "foo.bar"), double(:name => "foo.foo")])

      expect(provider.api).to receive(:upload_asset).with(anything, "bar.txt", {:name=>"bar.txt", :content_type=>"text/plain"})
      expect(provider).to receive(:log).with("foo.bar already exists, skipping.")

      provider.push_app
    end

    example "When Release Doesn't Exist" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["test/foo.bar", "bar.txt"])

      allow(provider).to receive(:releases).and_return([""])

      provider.releases.map do |release|
        allow(release).to receive(:tag_name).and_return("foo")
        allow(release).to receive(:rels).and_return({:self => nil})
        allow(release.rels[:self]).to receive(:href)
      end

      allow(provider.api).to receive(:create_release)
      allow(provider.api.create_release).to receive(:rels).and_return({:self => nil})
      allow(provider.api.create_release.rels[:slef]).to receive(:href)

      allow(provider.api).to receive(:release)
      allow(provider.api.release).to receive(:rels).and_return({:assets => nil})
      allow(provider.api.release.rels[:assets]).to receive(:get).and_return({:data => nil})
      allow(provider.api.release.rels[:assets].get).to receive(:data).and_return([])

      expect(provider.api).to receive(:upload_asset).with(anything, "test/foo.bar", {:name=>"foo.bar", :content_type=>"application/octet-stream"})
      expect(provider.api).to receive(:upload_asset).with(anything, "bar.txt", {:name=>"bar.txt", :content_type=>"text/plain"})

      provider.push_app
    end

    example "With Release Number" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["bar.txt"])
      provider.options.update(:release_number => "1234")

      allow(provider).to receive(:slug).and_return("foo/bar")

      allow(provider.api).to receive(:release)
      allow(provider.api.release).to receive(:rels).and_return({:assets => nil})
      allow(provider.api.release.rels[:assets]).to receive(:get).and_return({:data => nil})
      allow(provider.api.release.rels[:assets].get).to receive(:data).and_return([])

      expect(provider.api).to receive(:upload_asset).with("https://api.github.com/repos/foo/bar/releases/1234", "bar.txt", {:name=>"bar.txt", :content_type=>"text/plain"})

      provider.push_app
    end
  end
end
