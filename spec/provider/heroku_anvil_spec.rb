require 'spec_helper'
require 'anvil'
require 'heroku-api'
require 'excon'
require 'dpl/provider/heroku'

describe DPL::Provider::Heroku do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :api_key => 'foo', :strategy => 'anvil', :buildpack => 'git://some-buildpack.git')
  end

  describe "#api" do
    it 'accepts an api key' do
      api = double(:api)
      expect { provider.api }.not_to raise_error
    end

    it 'raises an error if an api key is not present' do
      provider.options.delete :api_key
      expect { provider.api }.to raise_error(DPL::Error)
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

    describe "#push_app" do
      example do
        response = double :response
        allow(response).to receive_messages(:status => 202)
        allow(response).to receive_messages(:headers => {'Location' => '/blah'})

        second_response = double :second_response
        allow(second_response).to receive_messages(:status => 200)

        allow(provider).to receive_messages(:slug_url => "http://slug-url")

        expect(ENV).to receive(:[]).with('TRAVIS_COMMIT').and_return('123')
        expect(::Excon).to receive(:post).with(provider.release_url,
                                        :body => {"slug_url" => "http://slug-url", "description" => "Deploy 123 via Travis CI" }.to_json,
                                         :headers => {"Content-Type" => 'application/json', 'Accept' => 'application/json'}).and_return(response)

        expect(::Excon).to receive(:get).with("https://:#{provider.options[:api_key]}@cisaurus.heroku.com/blah").and_return(second_response)
        provider.push_app
      end
    end

    describe "#slug_url" do

      before(:each) do
        headers = double(:headers)
        expect(::Anvil).to receive(:headers).at_least(:twice).and_return(headers)
        expect(headers).to receive(:[]=).at_least(:once).with('X-Heroku-User', "foo@bar.com")
        expect(headers).to receive(:[]=).at_least(:once).with('X-Heroku-App', "example")
      end

      example "with full buildpack url" do
        expect(::Anvil::Engine).to receive(:build).with(".", :buildpack=>"git://some-buildpack.git")
        provider.slug_url
      end

      example "with buildpack name expansion" do
        DPL::Provider::Heroku::Anvil::HEROKU_BUILDPACKS.each do |b|
          provider.options.update(:buildpack => b)
          expect(::Anvil::Engine).to receive(:build).with(".", :buildpack=>described_class::Anvil::HEROKU_BUILDPACK_PREFIX + b + ".git")
          provider.slug_url
        end
      end
    end
  end
end
