require 'spec_helper'
require 'dpl/provider/heroku'
require 'faraday'

describe DPL::Provider::Heroku do
  let(:api_key) { 'foo' }
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

  subject(:provider) do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => api_key, :strategy => "api")
  end

  let(:expected_headers) do
    { "Authorization" => "Bearer #{api_key}", "Accept" => "application/vnd.heroku+json; version=3" }
  end

  let(:api_url) { 'https://api.heroku.com' }

  describe "#ssh" do
    it "doesn't require an ssh key" do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#api" do
    it 'accepts an api key' do
      faraday = double(:faraday)
      expect(Faraday).to receive(:new).with(url: api_url, :headers => expected_headers).and_return(faraday)
      expect(provider.faraday).to eq(faraday)
    end

    it 'accepts a user and a password' do
      faraday = double(:faraday)
      provider.options.update(:user => "foo", :password => "bar")
      expect(Faraday).to receive(:new).with(url: api_url, :user => "foo", :password => "bar", :headers => expected_headers).and_return(faraday)
      expect(provider.faraday).to eq(faraday)
    end
  end

  describe "#trigger_build" do
    it "does not initiate legacy API object" do
      expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
      expect(::Heroku::API).not_to receive(:new)
      provider.trigger_build
    end

    example do
      expect(provider).to receive(:log).with('triggering new deployment')
      expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
      expect(provider).to receive(:get_url).and_return 'http://example.com/source.tgz'
      expect(provider).to receive(:version).and_return 'v1.3.0'
      expect(provider.context).to receive(:shell).with('curl https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef')
      provider.trigger_build
      expect(provider.build_id).to eq('01234567-89ab-cdef-0123-456789abcdef')
    end
  end

  describe "#verify_build" do
    context 'when build succeeds' do
      example do
        expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
        expect(provider).to receive(:build_id).at_least(:once).and_return('01234567-89ab-cdef-0123-456789abcdef')
        expect{ provider.verify_build }.not_to raise_error
      end
    end

    context 'when build fails' do
      example do
        expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
        expect(provider).to receive(:build_id).at_least(:once).and_return('01234567-89ab-cdef-0123-456789abcdef')
        stubs.get("/apps/example/builds/01234567-89ab-cdef-0123-456789abcdef/result") {|env| [200, response_headers, build_result_response_body_failure]}
        expect{ provider.verify_build }.to raise_error("deploy failed, build exited with code 1")
      end
    end

    context 'when build is pending, then succeeds' do
      example do
        expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
        expect(provider).to receive(:build_id).at_least(:once).and_return('01234567-89ab-cdef-0123-456789abcdef')
        stubs.get("/apps/example/builds/01234567-89ab-cdef-0123-456789abcdef/result") {|env| [200, response_headers, build_result_response_body_in_progress]}
        expect(provider).to receive(:sleep).with(5) # stub sleep
        expect{ provider.verify_build }.not_to raise_error
      end
    end

  end

end
