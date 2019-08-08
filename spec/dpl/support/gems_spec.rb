require 'dpl/support/gems'

describe Dpl::Support::Gems::Parse do
  let(:code) do
    <<-code
      module Dpl
        module Providers
          class CloudFiles < Provider
            gem 'nokogiri', '< 1.10'
            gem 'fog-core', '= 2.1.0', require: 'fog/core'
            gem 'fog-rackspace', '~> 0.1.6', require: 'fog/rackspace'
          end
        end
      end
    code
  end

  subject { described_class.new(code).gems }

  it do
    should eq [
      ['nokogiri', '< 1.10', {}],
      ['fog-core', '= 2.1.0', require: 'fog/core'],
      ['fog-rackspace', '~> 0.1.6', require: 'fog/rackspace'],
    ]
  end
end
