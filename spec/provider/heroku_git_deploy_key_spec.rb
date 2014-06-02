require 'spec_helper'
require 'heroku-api'
require 'dpl/provider/heroku'

describe DPL::Provider::Heroku do
  subject(:provider) do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => "foo", :strategy => "gitdeploykey")
  end

  describe "#ssh" do
    it "doesn't require an ssh key" do
      provider.needs_key?.should == false
    end
  end
end
