# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
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
      expect { provider.check_app }.to raise_error(/Cannot deploy to inexisting app/)
    end
  end

  describe '#convox_promote' do
    it 'should default to true' do
      provider.options.delete(:promote)
      expect(provider.convox_promote).to be true
    end
  end

  describe '#push_app' do
    it 'only builds app if promote is set to false' do
      provider.options.update(promote: false)
      provider.options.update(description: 'MySuperDescription')
      allow(provider).to receive(:update_envs)
      expect(provider).not_to receive(:convox_deploy)
      expect(provider.context).to receive(:shell)
        .with('convox build --rack sample/rack --app example-app --id --description MySuperDescription')
        .and_return(true)
      provider.push_app
    end

    it 'builds and promotes app if promote is set to true' do
      provider.options.update(promote: true)
      provider.options.update(description: 'My Extra Description')
      allow(provider).to receive(:update_envs)
      expect(provider).not_to receive(:convox_build)
      expect(provider.context).to receive(:shell)
        .with('convox deploy --rack sample/rack --app example-app --wait --id --description My\ Extra\ Description')
        .and_return(true)
      provider.push_app
    end

    it 'should set name-passed environments' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.update(env: %w[
                                VAR1
                                SomeVar
                              ])
      expect(provider).to receive(:update_envs)
      provider.push_app
    end

    it 'should set environments if provided' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.update(env: [
                                'VAR1=1111',
                                'SomeVar=14141'
                              ])
      expect(provider).to receive(:update_envs)
      provider.push_app
    end

    it 'should not touch environments if option is not provided' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.delete(:env)
      expect(provider).not_to receive(:update_envs)
      provider.push_app
    end

    it 'should set environments even if empty array provided' do
      provider.options.update(promote: true)
      allow(provider).to receive(:convox_deploy).and_return(true)

      provider.options.update(env: [])
      expect(provider).to receive(:update_envs)
      provider.push_app
    end
  end

  describe '#update_envs' do
    it 'should clear environments when none provided' do
      provider.options.update(env: [])
      expect(provider.context).to receive(:shell)
        .with('convox env set  --rack sample/rack --app example-app --replace')
        .and_return(true)
      provider.update_envs
    end

    it 'should set environments when string provided' do
      provider.options.update(env: 'VAR1=someVarValue')
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'VAR1=someVarValue' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should set environments when list of 3 provided' do
      provider.options.update(env: [
                                'VAR1=someVarValue',
                                'SOME_VAR=this_is_a_value',
                                'VAR_WITH_SPACES=there should be spaces here'
                              ])
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'VAR1=someVarValue' 'SOME_VAR=this_is_a_value' 'VAR_WITH_SPACES=there should be spaces here' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should set environments even when only their names provided' do
      allow(provider.context.env).to receive(:[]).with('VAR1000').and_return('varFetchedFromOS')
      allow(provider.context.env).to receive(:[]).with('SOME_SYS_VAR').and_return('This is a var')

      provider.options.update(env: %w[
                                VAR1000
                                SOME_SYS_VAR
                              ])
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'VAR1000=varFetchedFromOS' 'SOME_SYS_VAR=This is a var' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should escape single-quotes' do
      provider.options.update(env: %(SINGLE_QUOTE=myPass'Word''has single quotes))
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'SINGLE_QUOTE=myPass'"'"'Word'"'"''"'"'has single quotes' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end
  end

  describe '#update_envs with file' do
    before :all do
      @tmpfile = Tempfile.new('myvars.txt')
      @tmpfile.write("SOME_FILE_VAR1=lalala\nANOTHER_VAR_EXAMPLE=yupiii\n")
      @tmpfile.close
    end

    after :all do
      @tmpfile.unlink
    end

    it 'should set environments when file provided' do
      provider.options.update(env_file: @tmpfile.path)
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'SOME_FILE_VAR1=lalala' 'ANOTHER_VAR_EXAMPLE=yupiii' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should set mixed environments when file provided and envs are provided' do
      provider.options.update(env_file: @tmpfile.path)
      provider.options.update(env: [
                                'VAR1=someVarValue',
                                'VAR2_IN=got_this_value_here'
                              ])
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'SOME_FILE_VAR1=lalala' 'ANOTHER_VAR_EXAMPLE=yupiii' 'VAR1=someVarValue' 'VAR2_IN=got_this_value_here' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end

    it 'should combine mixed environments and overwrite those from file with direct ones' do
      provider.options.update(env_file: @tmpfile.path)
      provider.options.update(env: [
                                'ANOTHER_VAR_EXAMPLE=this-is-direct-one',
                                'VAR2_IN=got_this_value_here'
                              ])
      expect(provider.context).to receive(:shell)
        .with(%(convox env set 'SOME_FILE_VAR1=lalala' 'ANOTHER_VAR_EXAMPLE=yupiii' 'ANOTHER_VAR_EXAMPLE=this-is-direct-one' 'VAR2_IN=got_this_value_here' --rack sample/rack --app example-app --replace))
        .and_return(true)
      provider.update_envs
    end
  end
end
