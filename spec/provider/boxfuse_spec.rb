require 'spec_helper'
require 'dpl/provider/boxfuse'

describe DPL::Provider::Boxfuse do
  subject :provider do
    described_class.new(DummyContext.new, :user => 'dummyuser', :image => 'abc:123')
  end

  describe "#deploy" do
    example do
      expect(provider.context).to receive(:shell).with('curl -L https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz | tar xz')
      expect(provider.context).to receive(:shell).with('boxfuse/boxfuse run -user=dummyuser -image=abc:123 -env=test')
      provider.deploy
    end
  end
end
