require 'forwardable'
require 'cl'

module Dpl
  module Provider
    class Base < Cl::Cmd
      extend Forwardable

      # tell Cl that this is not meant to be an executable command
      abstract

      # opt '--pretend', 'Pretend running the deployment'
      # opt '--quiet',   'Suppress any output'

      def_delegators :ctx, :shell

      def run
        fold do
          prepare
          deploy
        end
      end

      def prepare
      end

      def deploy
        shell cmd
      end

      def fold(&block)
        ctx.fold('Deploying application', &block)
      end

      def check_auth
      end

      def needs_key?
      end

      def name
        registry_key
      end

      def to_opts(keys)
        keys.map { |key| "--#{key}=#{send(key)}" if send(:"#{key}?") }
      end

      def deprectated_opt(old, new)
        ctx.deprecate_opt(old, new)
        opts[old]
      end
    end
  end
end
