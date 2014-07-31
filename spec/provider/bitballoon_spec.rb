require 'spec_helper'
require 'dpl/provider/bitballoon'

describe DPL::Provider::BitBalloon do
  subject :provider do
    described_class.new(DummyContext.new, access_token:'fake-access-token', site_id:'fake-site')
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "Without :local_dir" do
      expect(provider.context).not_to receive(:shell).with("./")
      provider.push_app
    end
    example "With :app" do
      provider.options.update(local_dir: 'build')

      expected_command = "bitballoon deploy ./build --site-id=fake-site --access-token=fake-access-token"

      expect(provider.context).to receive(:shell).with(expected_command)
      provider.push_app
    end
  end
end
