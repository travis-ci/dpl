require 'spec_helper'
require 'dpl/provider/catalyze'

describe DPL::Provider::Catalyze do
  subject :provider do
    described_class.new(DummyContext.new, :target => 'test-target', :path => 'test-path')
  end

  describe "#check_auth" do
    it 'should require a target' do
      provider.options.update(:target => nil)
      expect{ provider.check_auth }.to raise_error("Missing Catalyze target")
    end
  end

  describe "#push_app" do
    it 'should push the current branch to the target' do
      expect(provider.context).to receive(:shell).with("git push --force test-target HEAD:master")
      provider.push_app
    end
    it 'should add and commit local build files if skip_cleanup is true' do
      provider.options.update(:skip_cleanup => true)
      expect(provider.context).to receive(:shell).with("git checkout HEAD")
      expect(provider.context).to receive(:shell).with("git add test-path --all --force")
      expect(provider.context).to receive(:shell).with("git commit -m \"Local build\" --quiet")
      expect(provider.context).to receive(:shell).with("git push --force test-target HEAD:master")
      provider.push_app
    end
    it 'should use a path of "." if the path is not specified' do
      provider.options.update(:path => nil)
      provider.options.update(:skip_cleanup => true)
      expect(provider.context).to receive(:shell).with("git checkout HEAD")
      expect(provider.context).to receive(:shell).with("git add . --all --force")
      expect(provider.context).to receive(:shell).with("git commit -m \"Local build\" --quiet")
      expect(provider.context).to receive(:shell).with("git push --force test-target HEAD:master")
      provider.push_app
    end
  end
end
