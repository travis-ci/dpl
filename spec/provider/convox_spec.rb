# frozen_string_literal: true

require 'spec_helper'
require 'dpl/provider/convox'

describe DPL::Provider::Convox do
  let(:options) do
    {
      app: 'example-app',
      rack: 'sample/rack',
      password: 'secret-passwd'
    }
  end

  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  describe '#check_auth' do
    example do
      expect(provider.context).to receive(:shell)
        .with('./convox version')
        .and_return(true)
      provider.check_auth
    end
  end

  describe '#check_app' do
    it 'checks if app exists by calling proper shell command once' do
      expect(provider.context).to receive(:shell)
        .with('./convox apps info --rack sample/rack --app example-app')
        .and_return(true)
      expect(provider.context).not_to receive(:shell)
        .with('./convox apps create example-app --generation 2 --rack sample/rack --wait')
      provider.check_app
    end

    it "creates new app if app doesn't exist" do
      expect(provider.context).to receive(:shell)
        .with('./convox apps info --rack sample/rack --app example-app')
        .and_return(false)
      expect(provider.context).to receive(:shell)
        .with('./convox apps create example-app --generation 2 --rack sample/rack --wait')
        .and_return(true)
      provider.check_app
    end
  end

  describe '#push_app' do
    it 'only builds app if promote is set to false' do
      provider.options[:promote] = false
      expect(provider).to receive(:convox_build)
      expect(provider).not_to receive(:convox_deploy)
      provider.push_app
    end

    it 'builds and promotes app if promote is set to true' do
      provider.options[:promote] = true
      expect(provider).not_to receive(:convox_build)
      expect(provider).to receive(:convox_deploy)
      provider.push_app
    end
  end
end
