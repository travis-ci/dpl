require 'spec_helper'
require 'dpl/provider/releases'
require 'octokit'

describe DPL::Provider::Releases do
  subject :provider do
    described_class.new(DummyContext.new, :api_key => '0123445789qwertyuiop0123445789qwertyuiop', :file => 'blah.txt')
  end

  describe :api do
    example "With API key" do
      api = double(:api)
      ::Octokit::Client.should_receive(:new).with(:access_token => '0123445789qwertyuiop0123445789qwertyuiop').and_return(api)
      provider.api.should be == api
    end

    example "With username and password" do
      api = double(:api)
      provider.options.update(:user => 'foo')
      provider.options.update(:password => 'bar')

      ::Octokit::Client.should_receive(:new).with(:login => 'foo', :password  => 'bar').and_return(api)
      provider.api.should be == api
    end
  end

  describe :releases do
    example "With ENV Slug" do
      provider.stub(:slug).and_return("foo/bar")

      provider.api.should_receive(:releases).with("foo/bar")
      provider.releases
    end

    example "With repo option" do
      provider.options.update(:repo => 'bar/foo')

      provider.api.should_receive(:releases).with('bar/foo')
      provider.releases
    end
  end

  describe :needs_key? do
    example do
      provider.needs_key?.should == false
    end
  end

  describe :check_auth do
    example "With proper permissions" do
      allow_message_expectations_on_nil
      provider.stub(:user)
      provider.stub(:setup_auth)
      provider.api.should_receive(:scopes).and_return(["public_repo"])
      provider.user.should_receive(:name).and_return("foo")
      provider.should_receive(:log).with("Logged in as foo")
      provider.check_auth
    end

    example "With improper permissions" do
      allow_message_expectations_on_nil
      provider.stub(:user)
      provider.stub(:setup_auth)
      provider.api.should_receive(:scopes).exactly(2).times.and_return([])
      expect { provider.check_auth }.to raise_error(DPL::Error)
    end
  end

  describe :push_app do
    example "When Release Exists but has no Files" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["test/foo.bar", "bar.foo"])

      provider.stub(:releases).and_return([""])
      provider.stub(:get_tag).and_return("v0.0.0")

      provider.releases.map do |release| 
        release.stub(:tag_name).and_return("v0.0.0")
        release.stub(:rels).and_return({:self => nil})
        release.rels[:self].stub(:href)
      end

      provider.api.stub(:release)
      provider.api.release.stub(:rels).and_return({:assets => nil})
      provider.api.release.rels[:assets].stub(:get).and_return({:data => [""]})
      provider.api.release.rels[:assets].get.stub(:data).and_return([])

      provider.api.should_receive(:upload_asset).with(anything, "test/foo.bar", {:name=>"foo.bar", :content_type=>""})
      provider.api.should_receive(:upload_asset).with(anything, "bar.foo", {:name=>"bar.foo", :content_type=>""})

      provider.push_app
    end

    example "When Release Exists and has Files" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["test/foo.bar", "bar.foo"])

      provider.stub(:releases).and_return([""])
      provider.stub(:get_tag).and_return("v0.0.0")

      provider.releases.map do |release| 
        release.stub(:tag_name).and_return("v0.0.0")
        release.stub(:rels).and_return({:self => nil})
        release.rels[:self].stub(:href)
      end

      provider.api.stub(:release)
      provider.api.release.stub(:rels).and_return({:assets => nil})
      provider.api.release.rels[:assets].stub(:get).and_return({:data => [""]})
      provider.api.release.rels[:assets].get.stub(:data).and_return([double(:name => "foo.bar"), double(:name => "foo.foo")])

      provider.api.should_receive(:upload_asset).with(anything, "bar.foo", {:name=>"bar.foo", :content_type=>""})
      provider.should_receive(:log).with("foo.bar already exists, skipping.")

      provider.push_app
    end

    example "When Release Doesn't Exist" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["test/foo.bar", "bar.foo"])

      provider.stub(:releases).and_return([""])
      
      provider.releases.map do |release| 
        release.stub(:tag_name).and_return("foo")
        release.stub(:rels).and_return({:self => nil})
        release.rels[:self].stub(:href)
      end

      provider.api.stub(:create_release)
      provider.api.create_release.stub(:rels).and_return({:self => nil})
      provider.api.create_release.rels[:slef].stub(:href)

      provider.api.stub(:release)
      provider.api.release.stub(:rels).and_return({:assets => nil})
      provider.api.release.rels[:assets].stub(:get).and_return({:data => nil})
      provider.api.release.rels[:assets].get.stub(:data).and_return([])

      provider.api.should_receive(:upload_asset).with(anything, "test/foo.bar", {:name=>"foo.bar", :content_type=>""})
      provider.api.should_receive(:upload_asset).with(anything, "bar.foo", {:name=>"bar.foo", :content_type=>""})

      provider.push_app
    end

    example "With Release Number" do
      allow_message_expectations_on_nil

      provider.options.update(:file => ["bar.foo"])
      provider.options.update(:release_number => "1234")

      provider.stub(:slug).and_return("foo/bar")

      provider.api.stub(:release)
      provider.api.release.stub(:rels).and_return({:assets => nil})
      provider.api.release.rels[:assets].stub(:get).and_return({:data => nil})
      provider.api.release.rels[:assets].get.stub(:data).and_return([])

      provider.api.should_receive(:upload_asset).with("https://api.github.com/repos/foo/bar/releases/1234", "bar.foo", {:name=>"bar.foo", :content_type=>""})

      provider.push_app
    end
  end
end
