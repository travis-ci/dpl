require 'spec_helper'
require 'dpl/provider/hackage'

describe DPL::Provider::Hackage do
  subject :provider do
    described_class.new(DummyContext.new, :username => 'FooUser', :password => 'bar')
  end

  describe :check_app do
    example do
      provider.context.should_receive(:shell).with("cabal check")
      provider.check_app
    end
  end

  describe :push_app do
    example do
      provider.context.should_receive(:shell).with("cabal sdist")
      Dir.should_receive(:glob).and_yield('dist/package-0.1.2.3.tar.gz')
      provider.context.should_receive(:shell).with("cabal upload --username=FooUser --password=bar dist/package-0.1.2.3.tar.gz")
      provider.push_app
    end
  end
end
