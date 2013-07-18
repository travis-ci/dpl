require 'spec_helper'
require 'dpl/provider'

describe DPL::Provider do
  let(:example_provider) { Class.new(described_class)}
  subject(:provider) { example_provider.new(DummyContext.new, :app => 'example', :key_name => 'foo', :run => ["foo", "bar"]) }

  before { described_class.const_set(:Example, example_provider) }
  after { described_class.send(:remove_const, :Example) }

  describe :new do
    example { described_class.new(DummyContext.new, :provider => "example") .should be_an(example_provider) }
    example { described_class.new(DummyContext.new, :provider => "Example") .should be_an(example_provider) }
    example { described_class.new(DummyContext.new, :provider => "exa_mple").should be_an(example_provider) }
    example { described_class.new(DummyContext.new, :provider => "exa-mple").should be_an(example_provider) }
  end

  describe :requires do
    before do
      example_provider.should_receive(:require).with("foo")
    end

    example "installed" do
      example_provider.should_receive(:gem).with("foo", "~> 1.4")
      example_provider.requires("foo", :version => "~> 1.4")
    end

    example "missing" do
      example_provider.should_receive(:gem).with("foo", "~> 1.4").and_raise(LoadError)
      example_provider.context.should_receive(:shell).with('gem install foo -v "~> 1.4"')
      example_provider.requires("foo", :version => "~> 1.4")
    end
  end

  describe :pip do
    example "installed" do
      example_provider.should_receive(:`).with("which foo").and_return("/bin/foo\n")
      example_provider.should_not_receive(:system)
      example_provider.pip("foo")
    end

    example "missing" do
      example_provider.should_receive(:`).with("which foo").and_return("")
      example_provider.context.should_receive(:shell).with("pip install foo")
      example_provider.pip("foo")
    end
  end

  describe :deploy do
    before do
      provider.should_receive(:check_auth)
      provider.should_receive(:check_app)
      provider.should_receive(:push_app)
      provider.should_receive(:run).with("foo")
      provider.should_receive(:run).with("bar")
    end

    example "needs key" do
      provider.should_receive(:remove_key)
      provider.should_receive(:create_key)
      provider.should_receive(:setup_key)
      provider.should_receive(:setup_git_ssh)
      provider.deploy
    end

    example "does not need key" do
      provider.stub(:needs_key?, false)
      provider.deploy
    end
  end

  describe :create_key do
    example do
      provider.context.should_receive(:shell).with('ssh-keygen -t rsa -N "" -C foo -f thekey')
      provider.create_key('thekey')
    end
  end

  describe :setup_git_ssh do
    after { FileUtils.rm ENV.delete('GIT_SSH') }

    example do
      provider.setup_git_ssh('foo', 'bar')
      ENV['GIT_SSH'].should be == File.expand_path('foo')
    end
  end

  describe :log do
    example do
      $stderr.should_receive(:puts).with("foo")
      provider.log("foo")
    end
  end
end