require 'spec_helper'
require 'dpl/provider'

describe DPL::Provider do
  let(:example_provider) { Class.new(described_class)}
  subject(:provider) { example_provider.new(DummyContext.new, :app => 'example', :key_name => 'foo', :run => ["foo", "bar"]) }

  before { stub_const "DPL::Provider::Example", example_provider }

  describe "#new" do
    example { expect(described_class.new(DummyContext.new, :provider => "example")) .to be_an(example_provider) }
    example { expect(described_class.new(DummyContext.new, :provider => "Example")) .to be_an(example_provider) }
    example { expect(described_class.new(DummyContext.new, :provider => "exa_mple")).to be_an(example_provider) }
    example { expect(described_class.new(DummyContext.new, :provider => "exa-mple")).to be_an(example_provider) }
  end

  describe "#requires" do
    before do
      expect(example_provider).to receive(:require).with("foo")
    end

    example "installed" do
      expect(example_provider).to receive(:gem).with("foo", "~> 1.4")
      example_provider.requires("foo", :version => "~> 1.4")
    end

    example "missing" do
      expect(example_provider).to receive(:gem).with("foo", "~> 1.4").and_raise(LoadError)
      expect(example_provider.context).to receive(:shell).with('gem install foo -v "~> 1.4"', retry: true)
      example_provider.requires("foo", :version => "~> 1.4")
    end
  end

  describe "#apt_get" do
    example "installed" do
      expect(example_provider).to receive(:`).with("which foo").and_return("/bin/foo\n")
      expect(example_provider).not_to receive(:system)
      example_provider.apt_get("foo")
    end

    example "missing" do
      expect(example_provider).to receive(:`).with("which foo").and_return("")
      expect(example_provider.context).to receive(:shell).with("sudo apt-get -qq install foo", retry: true)
      example_provider.apt_get("foo")
    end
  end

  describe "#pip" do
    example "installed" do
      expect(example_provider).to receive(:`).with("which foo").and_return("/bin/foo\n")
      expect(example_provider).not_to receive(:system)
      example_provider.pip("foo")
    end

    example "missing" do
      expect(example_provider).to receive(:`).with("which foo").and_return("")
      expect(example_provider.context).to receive(:shell).with("sudo pip install foo", retry: true)
      example_provider.pip("foo")
    end
  end

  describe "#deploy" do
    before do
      expect(provider).to receive(:check_auth)
      expect(provider).to receive(:check_app)
      expect(provider).to receive(:push_app)
      expect(provider).to receive(:run).with("foo")
      expect(provider).to receive(:run).with("bar")
    end

    example "needs key" do
      expect(provider).to receive(:remove_key)
      expect(provider).to receive(:create_key)
      expect(provider).to receive(:setup_key)
      expect(provider).to receive(:setup_git_ssh)
      provider.deploy
    end

    example "does not need key" do
      allow(provider).to receive_messages(:needs_key? => false)
      provider.deploy
    end
  end

  describe "#cleanup" do
    example do
      expect(provider.context).to receive(:shell).with('mv .dpl ~/dpl')
      expect(provider.context).to receive(:shell).with('git stash --all')
      expect(provider.context).to receive(:shell).with('mv ~/dpl .dpl')
      provider.cleanup
    end

    example "skip cleanup" do
      expect(provider.options).to receive(:[]).with(:skip_cleanup).and_return("true")
      expect(provider.context).not_to receive(:shell)
      provider.cleanup
    end
  end

  describe "#uncleanup" do
    example do
      expect(provider.context).to receive(:shell).with('git stash pop')
      provider.uncleanup
    end

    example "skip cleanup" do
      expect(provider.options).to receive(:[]).with(:skip_cleanup).and_return("true")
      expect(provider.context).not_to receive(:shell)
      provider.uncleanup
    end
  end

  describe "#create_key" do
    example do
      expect(provider.context).to receive(:shell).with('ssh-keygen -t rsa -N "" -C foo -f thekey')
      provider.create_key('thekey')
    end
  end

  describe "#setup_git_ssh" do
    after { FileUtils.rm ENV.delete('GIT_SSH') }

    example do
      provider.setup_git_ssh('foo', 'bar')
      expect(ENV['GIT_SSH']).to eq(File.expand_path('foo'))
    end
  end

  describe "#log" do
    example do
      expect($stderr).to receive(:puts).with("foo")
      provider.log("foo")
    end
  end

  describe "#shell" do
    example do
      expect(example_provider).to receive(:system).with("command")
      example_provider.shell("command")
    end
  end

  describe "#npm_g" do
    example do
      expect(example_provider.context).to receive(:shell).with("npm install -g foo", retry: true)
      example_provider.npm_g("foo")
    end
  end

  describe "#run" do
    example do
      expect(provider).to receive(:error).with("running commands not supported")
      provider.run "blah"
    end
  end

  describe "#error" do
    example do
      expect { provider.error("Foo") }.to raise_error("Foo")
    end
  end
end
