require 'spec_helper'
require 'heroku-api'
require 'dpl/provider/heroku'
require 'faraday'

describe DPL::Provider::Heroku do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => "foo", :strategy => "git-ssh")
  end

  let(:api_key) {'foo'}
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:faraday) {
    Faraday.new do |builder|
      builder.adapter :test, stubs do |stub|
        stub.get("/account") {|env| [200, response_headers, account_response_body]}
        stub.post("/apps/example/builds") {|env| [201, response_headers, builds_response_body]}
        stub.get("/apps/example/builds/01234567-89ab-cdef-0123-456789abcdef/result") {|env| [200, response_headers, build_result_response_body]}
        stub.post("/sources") {|env| [201, response_headers, source_response_body] }
      end
    end
  }

  let(:response_headers) {
    {'Content-Type' => 'application/json'}
  }

  let(:account_response_body) {
'{
  "allow_tracking": true,
  "beta": false,
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@example.com",
  "federated": false,
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "identity_provider": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "organization": {
      "name": "example"
    }
  },
  "last_login": "2012-01-01T12:00:00Z",
  "name": "Tina Edmonds",
  "sms_number": "+1 ***-***-1234",
  "suspended_at": "2012-01-01T12:00:00Z",
  "delinquent_at": "2012-01-01T12:00:00Z",
  "two_factor_authentication": false,
  "updated_at": "2012-01-01T12:00:00Z",
  "verified": false,
  "default_organization": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  }
}'
  }

  let(:builds_response_body) {
'{
  "app": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "buildpacks": [
    {
      "url": "https://github.com/heroku/heroku-buildpack-ruby"
    }
  ],
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef",
  "source_blob": {
    "checksum": "SHA256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "url": "https://example.com/source.tgz?token=xyz",
    "version": "v1.3.0"
  },
  "release": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "status": "succeeded",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  }
}'
  }

  let(:source_response_body) {
'{
  "source_blob": {
    "get_url": "https://api.heroku.com/sources/1234.tgz",
    "put_url": "https://api.heroku.com/sources/1234.tgz"
  }
}'
  }

  let(:build_result_response_body) {
'{
    "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "succeeded",
    "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef"
  },
  "exit_code": 0,
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}'
  }

  let(:build_result_response_body_failure) {
'{
    "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "failed",
    "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef"
  },
  "exit_code": 1,
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}'
  }

  let(:build_result_response_body_in_progress) {
'{
    "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "failed",
    "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef"
  },
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}'
  }

  let(:expected_headers) do
    { "Authorization" => "Bearer #{api_key}", "Accept" => "application/vnd.heroku+json; version=3" }
  end

  let(:api_url) { 'https://api.heroku.com' }


  describe "#api" do
    it 'accepts an api key' do
      api = double(:api)
      expect(::Heroku::API).to receive(:new).with(:api_key => "foo", :headers => expected_headers).and_return(api)
      expect(provider.api).to eq(api)
    end

    it 'accepts a user and a password' do
      api = double(:api)
      provider.options.update(:user => "foo", :password => "bar")
      expect(::Heroku::API).to receive(:new).with(:user => "foo", :password => "bar", :headers => expected_headers).and_return(api)
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
        expect(provider.context).to receive(:shell).with("git fetch origin $TRAVIS_BRANCH --unshallow")
        expect(provider.context).to receive(:shell).with("git push git://something HEAD:refs/heads/master -f")
        provider.push_app
        expect(provider.context.env['GIT_HTTP_USER_AGENT']).to include("dpl/#{DPL::VERSION}")
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
