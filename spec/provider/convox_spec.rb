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

  before :each do
    allow(provider).to receive(:log).with(anything).and_return(true)
  end

  describe '#check_auth' do
    example do
      expect(provider.context).to receive(:shell)
        .with('convox version --rack sample/rack')
        .and_return(true)
      provider.check_auth
    end
  end

  describe '#check_app' do
    it 'checks if app exists by calling proper shell command once' do
      expect(provider.context).to receive(:shell)
        .with('convox apps info --rack sample/rack --app example-app')
        .and_return(true)
      expect(provider.context).not_to receive(:shell)
        .with('convox apps create example-app --generation 2 --rack sample/rack --wait')
      provider.check_app
    end

    it "creates new app if app doesn't exist and create flag is true" do
      provider.options.update(create: true)
      expect(provider.context).to receive(:shell)
        .with('convox apps info --rack sample/rack --app example-app')
        .and_return(false)
      expect(provider.context).to receive(:shell)
        .with('convox apps create example-app --generation 2 --rack sample/rack --wait')
        .and_return(true)
      provider.check_app
    end

    it 'throws an error when app doesn\'t exist and create flag is not set' do
      provider.options.delete(:create)
      expect(provider.context).to receive(:shell)
        .with('convox apps info --rack sample/rack --app example-app')
        .and_return(false)
      expect { provider.check_app }.to raise_error(/Cannot deploy to inexistent app/)
    end
  end

  describe '#convox_promote' do
    it 'should default to false' do
      provider.options.delete(:promote)
      expect(provider.convox_promote).to be false
    end
  end

  describe '#push_app' do
    it 'only builds app if promote is set to false' do
      provider.options.update(promote: false)
      provider.options.update(description: 'MySuperDescription')
      allow(provider).to receive(:update_envs)
      expect(provider).not_to receive(:convox_deploy)
      expect(provider.context).to receive(:shell)
        .with('convox build --rack sample/rack --app example-app --id --description "MySuperDescription"')
        .and_return(true)
      provider.push_app
    end

    it 'builds and promotes app if promote is set to true' do
      provider.options.update(promote: true)
      provider.options.update(description: 'MySuperDescription')
      allow(provider).to receive(:update_envs)
      expect(provider).not_to receive(:convox_build)
      expect(provider.context).to receive(:shell)
        .with('convox deploy --rack sample/rack --app example-app --wait --id --description "MySuperDescription"')
        .and_return(true)
      provider.push_app
    end

    it 'should set environments if provided' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.update(environment: [
        'VAR1=1111',
        'SomeVar=14141'
      ])
      expect(provider).to receive(:update_envs)
      provider.push_app
    end

    it 'should not touch environments if option is not provided' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.delete(:environment)
      expect(provider).not_to receive(:update_envs)
      provider.push_app
    end

    it 'should set environments even if empty array provided' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.update(environment: [])
      expect(provider).to receive(:update_envs)
      provider.push_app
    end
  end

  describe '#update_envs' do
    it 'should clear environments when none provided' do
      provider.options.update(environment: [])
      expect(provider.context).to receive(:shell)
        .with('convox env set  --rack sample/rack --app example-app --replace')
        .and_return(true)
      provider.update_envs
    end

    it 'should set environments when string provided' do
      provider.options.update(environment: 'VAR1=someVarValue')
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'VAR1=someVarValue' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should set environments when list of 3 provided' do
      provider.options.update(environment: [
                                'VAR1=someVarValue',
                                'SOME_VAR=this_is_a_value',
                                'VAR_WITH_SPACES=there should be spaces here'
                              ])
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'VAR1=someVarValue' 'SOME_VAR=this_is_a_value' 'VAR_WITH_SPACES=there should be spaces here' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should escape single-quotes' do
      provider.options.update(environment: %(SINGLE_QUOTE=myPass'Word''has single quotes))
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'SINGLE_QUOTE=myPass'"'"'Word'"'"''"'"'has single quotes' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end
  end
end
