require 'spec_helper'
require 'dpl/provider/hackage'

describe DPL::Provider::Hackage do
  subject :provider do
    described_class.new(DummyContext.new, :username => 'FooUser', :password => 'bar')
  end

  describe "#check_auth" do
    it 'should require username' do
      provider.options.update(:username => nil)
      expect {
        provider.check_auth
      }.to raise_error(DPL::Error)
    end

    it 'should require password' do
      provider.options.update(:password => nil)
      expect {
        provider.check_auth
      }.to raise_error(DPL::Error)
    end
  end

  describe "#check_app" do
    it 'calls cabal' do
      expect(provider.context).to receive(:shell).with("cabal check").and_return(true)
      provider.check_app
    end

    it 'fails when cabal complains' do
      expect(provider.context).to receive(:shell).with("cabal check").and_return(false)
      expect {
        provider.check_app
      }.to raise_error(DPL::Error)
    end
  end

  describe "#push_app" do
    example do
      expect(provider.context).to receive(:shell).with("cabal sdist").and_return(true)
      expect(Dir).to receive(:glob).and_yield('dist/package-0.1.2.3.tar.gz')
      expect(provider.context).to receive(:shell).with("cabal upload --username=FooUser --password=bar dist/package-0.1.2.3.tar.gz")
      provider.push_app
    end
  end
end
