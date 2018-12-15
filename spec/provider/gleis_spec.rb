require 'spec_helper'
require 'dpl/provider/gleis'

describe DPL::Provider::Gleis do
  let(:options) do
    {
      app: 'sample',
      key_name: 'key',
      username: 'user@domain.tld',
      password: 'secret'
    }
  end

  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  describe "#install_deploy_dependencies" do
    example do
      expect(provider.context).to receive(:shell).with(
        'gem install gleis'
      ).and_return(true)
      provider.install_deploy_dependencies
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(true)
    end
  end

  describe "#check_auth" do
    example do
      expect(provider.context).to receive(:shell).with(
        'gleis auth login user@domain.tld secret --skip-keygen'
      ).and_return(true)
      provider.check_auth
    end
  end

  describe "#check_app" do
    example do
      expect(provider.context).to receive(:shell).with(
        'gleis app status -a sample'
      ).and_return(true)
      provider.check_app
    end
  end

  describe "#setup_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        'gleis auth key add key_file dpl_key'
      ).and_return(true)
      provider.setup_key('key_file')
    end
  end

  describe "#remove_key" do
    example do
      expect(provider.context).to receive(:shell).with(
        'gleis auth key remove dpl_key'
      ).and_return(true)
      provider.remove_key
    end
  end

  describe "#push_app" do
    before(:example) do
      create_git_url_file('.dpl/git-url')
    end

    after(:example) do
      delete_git_url_file('.dpl/git-url')
    end

    example do
      expect(provider.context).to receive(:shell).with(
        'git push  git://something HEAD:refs/heads/master'
      ).and_return(true)
      expect(provider.context).to receive(:shell).with(
        "gleis app git -a #{options[:app]} -q > .dpl/git-url"
      ).and_return(true)
      provider.push_app
    end

    def create_git_url_file(filename)
      File.open filename, 'w' do |file|
        file.write('git://something')
      end
    end

    def delete_git_url_file(filename)
      FileUtils.rm_f filename
    end
  end
end
