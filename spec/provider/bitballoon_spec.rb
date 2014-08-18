require 'spec_helper'
require 'dpl/provider/bitballoon'

describe DPL::Provider::BitBalloon do
  subject :provider do
    described_class.new(DummyContext.new,{})
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    example "Without optional parameters" do
      expect(provider.context).to receive(:shell).with("bitballoon deploy")
      provider.push_app
    end

    example "With optional parameters" do
      provider.options.update(local_dir: 'build')
      provider.options.update(access_token:'fake-access-token')
      provider.options.update(site_id:'fake-site')

      expected_command = "bitballoon deploy ./build --site-id=fake-site --access-token=fake-access-token"

      expect(provider.context).to receive(:shell).with(expected_command)
      provider.push_app
    end
  end
end
