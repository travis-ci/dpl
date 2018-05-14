require 'spec_helper'
require 'dpl/provider/snap'

describe DPL::Provider::Snap do
  after :each do
    remove_test_snaps
  end

  subject :provider do
    described_class.new(
      DummyContext.new, :token => 'test-token', :snap => test_snap_name,
      :channel => 'test-channel')
  end

  describe "#install_deploy_dependencies" do
    example do
      provider.install_deploy_dependencies
      expect(ENV['PATH'].split(':')).to include('/snap/bin')
    end
  end

  describe "#check_auth" do
    example "success" do
      allow(Open3).to receive(:capture3).with(
        "snapcraft login --with -", stdin_data: 'test-token').and_return(
          ['test-stdout', 'test-stderr', 0])

      expect(provider).to receive(:log).with("Attemping to login")
      expect(provider).to receive(:log).with("test-stdout")
      provider.check_auth
    end

    example "failure" do
      allow(Open3).to receive(:capture3).with(
        "snapcraft login --with -", stdin_data: 'test-token').and_return(
          ['test-stdout', 'test-stderr', 1])

      expect(provider).to receive(:log).with("Attemping to login")
      expect{provider.check_auth}.to raise_error(
        DPL::Error, "Failed to authenticate: test-stderr")
    end

    example "missing token" do
      allow(Open3).to receive(:capture3).with(
        "snapcraft login --with -", stdin_data: nil).and_return(
          ['test-stdout', 'test-stderr', 1])

      provider.options.delete(:token)
      expect(provider).to receive(:log).with("Attemping to login")
      expect{provider.check_auth}.to raise_error(DPL::Error, "Missing token")
    end
  end

  describe "#push_app" do
    example "existing snap" do
      # Create fake snap
      create_test_snap

      expect(provider.context).to receive(:shell).with(
        "snapcraft push #{test_snap_name} --release=test-channel").and_return(
          true)

      provider.push_app
    end

    example "no existing snap should fail" do
      expect{provider.push_app}.to raise_error(
        DPL::Error, "No snap found matching 'test.snap'")
    end

    example "missing snap" do
      provider.options.delete(:snap)
      expect{provider.push_app}.to raise_error(
        DPL::Error, "missing snap")
    end

    example "multiple matching snaps should fail" do
      create_test_snap "foo.snap"
      create_test_snap "bar.snap"
      provider.options[:snap] = "*.snap"
      expect{provider.push_app}.to raise_error(
        DPL::Error,
        "Multiple snaps found matching '*.snap': foo.snap, bar.snap")
    end

    example "missing channel should default to edge" do
      # Create fake snap
      create_test_snap

      provider.options.delete(:channel)

      expect(provider.context).to receive(:shell).with(
        "snapcraft push #{test_snap_name} --release=edge").and_return(true)

      provider.push_app
    end
  end

  private

  def test_snap_name
    "test.snap"
  end

  def create_test_snap(snap_name = test_snap_name)
    File.open snap_name, "w" do | file |
      file.write("test")
    end
  end

  def remove_test_snaps
    FileUtils.rm_f Dir.glob('*.snap')
  end
end
