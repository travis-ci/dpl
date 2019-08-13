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
      
      opt '--strategy NAME', 'Upload backend', default: 'gstore', enum: %w(gstore gcs), internal: true
      opt '--bucket NAME', 'Bucket to upload files to', type: :string
      opt '--dot_match', 'Upload dot files', default: false, type: :boolean
      opt '--log_level LEVEL', internal: true
      
    end
  end
end

require 'dpl/providers/gcs/gstore'
require 'dpl/providers/gcs/gcs'
