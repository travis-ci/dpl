require 'spec_helper'
require 'anvil'
require 'heroku-api'
require 'excon'
require 'dpl/provider/heroku'

describe DPL::Provider::Heroku do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :api_key => 'foo', :strategy => 'anvil', :buildpack => 'git://some-buildpack.git')
  end

  describe :api do
    it 'accepts an api key' do
      api = double(:api)
      lambda { provider.api }.should_not raise_error
    end

    it 'raises an error if an api key is not present' do
      provider.options.delete :api_key
      lambda { provider.api }.should raise_error(DPL::Error)
    end
  end

  context "with fake api" do
    let :api do
      double "api",
        :get_user => double("get_user", :body => { "email" => "foo@bar.com" }),
        :get_app  => double("get_app",  :body => { "name"  => "example", "git_url" => "GIT URL" })
    end

    before do
      ::Heroku::API.should_receive(:new).and_return(api)
      provider.api
    end

    describe :push_app do
      example do
        response = double :response
        response.stub(:status => 202)
        response.stub(:headers => {'Location' => '/blah'})

        second_response = double :second_response
        second_response.stub(:status => 200)

        provider.stub(:slug_url => "http://slug-url")

        ENV.should_receive(:[]).with('TRAVIS_COMMIT').and_return('123')
        ::Excon.should_receive(:post).with(provider.release_url,
                                        :body => {"slug_url" => "http://slug-url", "description" => "Deploy 123 via Travis CI" }.to_json,
                                         :headers => {"Content-Type" => 'application/json', 'Accept' => 'application/json'}).and_return(response)

        ::Excon.should_receive(:get).with("https://:#{provider.options[:api_key]}@cisaurus.heroku.com/blah").and_return(second_response)
        provider.push_app
      end
    end

    describe :slug_url do

      before(:each) do
        headers = double(:headers)
        ::Anvil.should_receive(:headers).at_least(:twice).and_return(headers)
        headers.should_receive(:[]=).at_least(:once).with('X-Heroku-User', "foo@bar.com")
        headers.should_receive(:[]=).at_least(:once).with('X-Heroku-App', "example")
      end

      example "with full buildpack url" do
        ::Anvil::Engine.should_receive(:build).with(".", :buildpack=>"git://some-buildpack.git")
        provider.slug_url
      end

      example "with buildpack name expansion" do
        DPL::Provider::Heroku::Anvil::HEROKU_BUILDPACKS.each do |b|
          provider.options.update(:buildpack => b)
          ::Anvil::Engine.should_receive(:build).with(".", :buildpack=>described_class::Anvil::HEROKU_BUILDPACK_PREFIX + b)
          provider.slug_url
        end
      end
    end
  end
end
