require 'spec_helper'
require 'dpl/cli'

describe DPL::CLI do
  describe :options do
    example { described_class.new.options[:app]                           .should be == File.basename(Dir.pwd) }
    example { described_class.new(:app => 'foo')            .options[:app].should be == 'foo'                  }
    example { described_class.new("--app=foo")              .options[:app].should be == 'foo'                  }
    example { described_class.new("--app")                  .options[:app].should be == true                   }
    example { described_class.new("--app=foo", "--app=bar") .options[:app].should be == ['foo', 'bar']         }

    example "error handling" do
      $stderr.should_receive(:puts).with('invalid option "app"')
      expect { described_class.new("app") }.to raise_error(SystemExit)
    end
  end

  describe :run do
    example "triggers deploy" do
      provider = double('provider')
      DPL::Provider.should_receive(:new).and_return(provider)
      provider.should_receive(:deploy)

      described_class.run("--provider=foo")
    end

    example "error handling" do
      $stderr.should_receive(:puts).with('missing provider')
      expect { described_class.run }.to raise_error(SystemExit)
    end

    example "error handling in debug mode" do
      expect { described_class.run("--debug") }.to raise_error(DPL::Error, 'missing provider')
    end
  end
end
