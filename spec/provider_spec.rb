require 'spec_helper'
require 'dpl/provider'

describe DPL::Provider do
  let(:example_provider) { Class.new(described_class)}
  subject(:provider) { example_provider.new(DummyContext.new, :app => 'example', :key_name => 'foo', :run => ["foo", "bar"]) }

  before { stub_const "DPL::Provider::Example", example_provider }

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
      example_provider.context.should_receive(:shell).with('gem install foo -v "~> 1.4"', retry: true)
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
      example_provider.context.should_receive(:shell).with("sudo pip install foo", retry: true)
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
      provider.stub(:needs_key? => false)
      provider.deploy
    end
  end

  describe :cleanup do
    example do
      provider.context.should_receive(:shell).with('mv .dpl ~/dpl')
      provider.context.should_receive(:shell).with('git stash --all')
      provider.context.should_receive(:shell).with('mv ~/dpl .dpl')
      provider.cleanup
    end

    example "skip cleanup" do
      provider.options.should_receive(:[]).with(:skip_cleanup).and_return("true")
      provider.context.should_not_receive(:shell)
      provider.cleanup
    end
  end

  describe :uncleanup do
    example do
      provider.context.should_receive(:shell).with('git stash pop')
      provider.uncleanup
    end

    example "skip cleanup" do
      provider.options.should_receive(:[]).with(:skip_cleanup).and_return("true")
      provider.context.should_not_receive(:shell)
      provider.uncleanup
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

  describe :shell do
    example do
      example_provider.should_receive(:system).with("command")
      example_provider.shell("command")
    end
  end

  describe :npm_g do
    example do
      example_provider.context.should_receive(:shell).with("npm install -g foo", retry: true)
      example_provider.npm_g("foo")
    end
  end

  describe :run do
    example do
      provider.should_receive(:error).with("running commands not supported")
      provider.run "blah"
    end
  end

  describe :error do
    example do
      expect { provider.error("Foo") }.to raise_error("Foo")
    end
  end
end
