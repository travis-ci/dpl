require 'spec_helper'
require 'dpl/provider'

describe DPL::Provider do
  let(:example_provider) { Class.new(described_class)}
  let(:context) { DummyContext.new }
  subject(:provider) { example_provider.new(context, :app => 'example', :key_name => 'foo', :run => ["foo", "bar"]) }

  before { stub_const "DPL::Provider::Example", example_provider }

  describe "#new" do
    example { expect(described_class.new(context, :provider => "example")) .to be_an(example_provider) }
    example { expect(described_class.new(context, :provider => "Example")) .to be_an(example_provider) }
    example { expect(described_class.new(context, :provider => "exa_mple")).to be_an(example_provider) }
    example { expect(described_class.new(context, :provider => "exa-mple")).to be_an(example_provider) }
    example { expect(described_class.new(context, :provider => "scri_pt")).to be_an(DPL::Provider::Script) }
    example { expect(described_class.new(context, :provider => "scri _pt")).to be_an(DPL::Provider::Script) }
    example { expect(described_class.new(context, :provider => "cloudfoundry")).to be_an(DPL::Provider::CloudFoundry) }
    example "install deployment dependencies" do
      expect_any_instance_of(described_class).to receive(:respond_to?).with(:install_deploy_dependencies).and_return(true)
      expect_any_instance_of(described_class).to receive(:install_deploy_dependencies)
      described_class.new(context, :provider => "example")
    end

    it "installs correct gem when provider name does not match" do
      expect(context).to receive(:shell).with("gem install dpl-cloud_foundry -v #{ENV['DPL_VERSION'] || DPL::VERSION}")
      expect(described_class).to receive(:require).with("dpl/provider/cloud_foundry").and_raise LoadError.new("cannot load such file -- dpl/provider/cloud_foundry")
      expect(described_class).to receive(:require).with("dpl/provider/cloud_foundry").and_call_original
      described_class.new(context, :provider => 'cloudfoundry')
    end

  end

  describe "#pip" do
    example "installed" do
      expect(example_provider).to receive(:`).with("which foo").and_return("/bin/foo\n")
      expect(example_provider).not_to receive(:system)
      expect(example_provider.context).to receive(:shell).with("export PATH=$PATH:$HOME/.local/bin")
      example_provider.pip("foo")
    end

    example "missing" do
      expect(example_provider).to receive(:`).with("which foo").and_return("")
      expect(example_provider.context).to receive(:shell).with("pip install --user foo", retry: true)
      expect(example_provider.context).to receive(:shell).with("export PATH=$PATH:$HOME/.local/bin")
      example_provider.pip("foo")
    end

    example "specific version" do
      expect(example_provider).to receive(:`).with("which foo").and_return("")
      expect(example_provider.context).to receive(:shell).with("pip install --user foo==1.0", retry: true)
      expect(example_provider.context).to receive(:shell).with("export PATH=$PATH:$HOME/.local/bin")
      example_provider.pip("foo", "foo", "1.0")
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
    after { FileUtils.rm provider.context.env.delete('GIT_SSH') }

    example do
      provider.setup_git_ssh('foo', 'bar')
      expect(provider.context.env['GIT_SSH']).to eq(File.expand_path('foo'))
    end
  end

  describe "#detect_encoding?" do
    example do
      provider.options.update(:detect_encoding => true)
      expect(provider.detect_encoding?).to eq(true)
    end
  end

  describe "#encoding_for" do
    example do
      path = 'foo.js'
      expect(provider).to receive(:`).at_least(1).times.with("file '#{path}'").and_return("#{path}: gzip compressed")
      expect(provider.encoding_for(path)).to eq('gzip')
    end

    example do
      path = 'file with a space'
      expect(provider).to receive(:`).at_least(1).times.with("file '#{path}'").and_return("#{path}: empty")
      expect(provider.encoding_for(path)).to be_nil
    end

    example do
      path = 'foo.js'
      expect(provider).to receive(:`).at_least(1).times.with("file '#{path}'").and_return("#{path}: ASCII text, with very long line")
      expect(provider.encoding_for(path)).to eq('text')
    end

    example do
      path = 'foo.js'
      provider.options.update(:default_text_charset => 'UTF-8')
      expect(provider).to receive(:`).at_least(1).times.with("file '#{path}'").and_return("#{path}: ASCII text, with very long line")
      expect(provider.encoding_for(path)).to eq('text')
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
