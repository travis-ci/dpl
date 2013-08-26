require 'spec_helper'
require 'rubygems'
require 'gems'
require 'dpl/provider/rubygems'

describe DPL::Provider::RubyGems do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :api_key => 'foo')
  end

  describe :api do
    example "with an api key" do
      ::Gems.should_receive(:key=).with('foo')
      provider.setup_auth
    end

    example "with a username and password" do
      provider.options.update(:user => 'test', :password => 'blah')
      provider.options.delete(:api_key)
      ::Gems.should_receive(:username=).with('test')
      ::Gems.should_receive(:password=).with('blah')
      provider.setup_auth
    end
  end

  describe :check_auth do
    example do
      provider.options.update(:user => 'test', :password => 'blah')
      provider.options.delete(:api_key)
      provider.should_receive(:log).with("Authenticated with username test")
      provider.check_auth
    end
  end

  describe :check_app do
    example do
      ::Gems.should_receive(:info).with('example').and_return({'name' => 'example'})
      provider.should_receive(:log).with("Found gem example")
      provider.check_app
    end
  end

  describe :push_app do
    after(:each) do
      File.should_receive(:new).with('File').and_return('Test file')
      provider.should_receive(:log).with('Yes!')
      provider.push_app
    end

    example "with options[:app]" do
      provider.options.update(:app => 'example')
      provider.context.should_receive(:shell).with("gem build example.gemspec")
      Dir.should_receive(:glob).with('example-*.gem').and_yield('File')
      ::Gems.should_receive(:push).with('Test file').and_return('Yes!')
    end

    example "with options[:gem]" do
      provider.options.update(:gem => 'example-gem')
      provider.context.should_receive(:shell).with("gem build example-gem.gemspec")
      Dir.should_receive(:glob).with('example-gem-*.gem').and_yield('File')
      ::Gems.should_receive(:push).with('Test file').and_return('Yes!')
    end

    example "with options[:gemspec]" do
      provider.options.update(:gemspec => 'blah.gemspec')
      provider.context.should_receive(:shell).with("gem build blah.gemspec")
      Dir.should_receive(:glob).with('blah-*.gem').and_yield('File')
      ::Gems.should_receive(:push).with('Test file').and_return('Yes!')
    end

    example "with options[:host]" do
      provider.options.update(:host => 'http://example.com')
      provider.context.should_receive(:shell).with("gem build example.gemspec")
      Dir.should_receive(:glob).with('example-*.gem').and_yield('File')
      ::Gems.should_receive(:push).with('Test file', host='http://example.com').and_return('Yes!')
    end
  end

  describe :setup_gem do
    example "with options[:gem] and options[:app] set" do
      provider.options.update(:gem => 'test', :app => 'blah')
      provider.setup_gem
      provider.options[:gem].should be == 'test'
    end

    example "with options[:app] set" do
      provider.options.update(:app => 'foo')
      provider.setup_gem
      provider.options[:gem].should be == 'foo'
    end

    example "with options[:gem] set" do
      provider.options.update(:gem => 'bar')
      provider.setup_gem
      provider.options[:gem].should be == 'bar'
    end
  end

  describe :gemspec do
    example do
      provider.options.update(:gemspec => 'test.gemspec')
      provider.gemspec.should be == 'test'
    end
  end
end
