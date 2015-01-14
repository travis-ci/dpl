require 'spec_helper'
require 'heroku-api'
require 'dpl/provider/heroku'

describe DPL::Provider::Heroku do
  subject(:provider) do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => "foo", :strategy => "api")
  end

  let(:expected_headers) do
    { "User-Agent" => "dpl/#{DPL::VERSION} heroku-rb/#{Heroku::API::VERSION}" }
  end

  describe "#ssh" do
    it "doesn't require an ssh key" do
      expect(provider.needs_key?).to eq(false)
    end
  end

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

  describe "#trigger_build" do
    let(:response_body) { {
      "created_at" => "2012-01-01T12:00:00Z",
      "id" => "abc",
      "status" => "pending",
      "stream_url" => "http://example.com/stream",
      "updated_at" => "2012-01-01T12:00:00Z",
      "user" => { "id" => "01234567-89ab-cdef-0123-456789abcdef", "email" => "username@example.com" }
    } }
    example do
      expect(provider).to receive(:log).with('triggering new deployment')
      expect(provider).to receive(:get_url).and_return 'http://example.com/source.tgz'
      expect(provider).to receive(:version).and_return 'sha'
      expect(provider).to receive(:post).with(
        :builds, source_blob: {url: 'http://example.com/source.tgz', version: 'sha'}
      ).and_return(response_body)
      expect(provider.context).to receive(:shell).with('curl http://example.com/stream')
      provider.trigger_build
      expect(provider.build_id).to eq('abc')
    end
  end

  describe "#verify_build" do
    let(:response_body) { {
      "build" => {
        "id" => "01234567-89ab-cdef-0123-456789abcdef",
        "status" => "succeeded"
      },
      "exit_code" => exit_code
    } }

    before do
      expect(provider).to receive(:build_id).and_return('abc')
      expect(provider).to receive(:get).with('builds/abc/result').and_return(response_body)
    end

    context 'when build exits with zero' do
      let(:exit_code) { 0 }

      example do
        expect{ provider.verify_build }.not_to raise_error
      end
    end

    context 'when build exists with non-zero' do
      let(:exit_code) { 1 }

      example do
        expect{ provider.verify_build }.to raise_error("deploy failed, build exited with code 1")
      end
    end

  end

end
