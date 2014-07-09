require 'spec_helper'
require 'heroku-api'
require 'dpl/provider/heroku'

describe DPL::Provider::Heroku do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => "foo", :strategy => "git")
  end

  describe "#api" do
    it 'accepts an api key' do
      api = double(:api)
      expect(::Heroku::API).to receive(:new).with(:api_key => "foo").and_return(api)
      expect(provider.api).to eq(api)
    end

    it 'accepts a user and a password' do
      api = double(:api)
      provider.options.update(:user => "foo", :password => "bar")
      expect(::Heroku::API).to receive(:new).with(:user => "foo", :password => "bar").and_return(api)
      expect(provider.api).to eq(api)
    end
  end

  context "with fake api" do
    let :api do
      double "api",
        :get_user => double("get_user", :body => { "email" => "foo@bar.com" }),
        :get_app  => double("get_app",  :body => { "name"  => "example", "git_url" => "GIT URL" })
    end

    before do
      expect(::Heroku::API).to receive(:new).and_return(api)
      provider.api
    end

    its(:api) { should be == api }

    describe "#check_auth" do
      example do
        expect(provider).to receive(:log).with("authenticated as foo@bar.com")
        provider.check_auth
      end
    end

    describe "#check_app" do
      example do
        expect(provider).to receive(:log).at_least(1).times.with(/example/)
        provider.check_app
        expect(provider.options[:git]).to eq("GIT URL")
      end
    end

    describe "#setup_key" do
      example do
        expect(File).to receive(:read).with("the file").and_return("foo")
        expect(api).to receive(:post_key).with("foo")
        provider.setup_key("the file")
      end
    end

    describe "#remove_key" do
      example do
        expect(api).to receive(:delete_key).with("key")
        provider.remove_key
      end
    end

    describe "#push_app" do
      example do
        provider.options[:git] = "git://something"
        expect(provider.context).to receive(:shell).with("git push git://something HEAD:refs/heads/master -f")
        provider.push_app
      end
    end

    describe "#run" do
      example do
        data = double("data", :body => { "rendezvous_url" => "rendezvous url" })
        expect(api).to receive(:post_ps).with("example", "that command", :attach => true).and_return(data)
        expect(Rendezvous).to receive(:start).with(:url => "rendezvous url")
        provider.run("that command")
      end
    end

    describe "#restart" do
      example do
        expect(api).to receive(:post_ps_restart).with("example")
        provider.restart
      end
    end

    describe "#deploy" do
      example "not found error" do
        expect(provider).to receive(:api) { raise ::Heroku::API::Errors::NotFound.new("the message", nil) }.at_least(:once)
        expect { provider.deploy }.to raise_error(DPL::Error, 'the message (wrong app "example"?)')
      end

      example "unauthorized error" do
        expect(provider).to receive(:api) { raise ::Heroku::API::Errors::Unauthorized.new("the message", nil) }.at_least(:once)
        expect { provider.deploy }.to raise_error(DPL::Error, 'the message (wrong API key?)')
      end
    end
  end
end
