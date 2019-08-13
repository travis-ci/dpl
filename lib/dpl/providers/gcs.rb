require 'kconv'

module Dpl
  module Providers
    class Gcs < Provider
      def self.new(ctx, args)
        # can this be a generic dispatch feature in Cl?
        return super unless registry_key.to_sym == :gcs
        arg = args.detect { |arg| arg.include?('--strategy') }
        strategy = arg ? arg.split('=').last : 'gstore'
        Provider[:"gcs:#{strategy}"].new(ctx, args)
      end
      
      
    end
  end
end

require 'dpl/providers/gcs/gstore'
require 'dpl/providers/gcs/gcs'
