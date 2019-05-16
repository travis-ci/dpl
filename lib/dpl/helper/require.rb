require 'dpl/version'

module Dpl
  class Require < Struct.new(:ctx, :const)
    extend Forwardable

    def run
      require
    rescue LoadError
      install
      require
    end

    private

      def require
        paths.each { |path| Kernel.require(path) }
      end

      def install
        ctx.shell "gem install #{gem_name} -v #{version}", echo: true, sudo: ctx.sudo?
      end

      def paths
        Array(const.requires)
      end

      def gem_name
        "dpl-#{const.registry_key.split(':').first}"
      end

      def version
        ENV['DPL_VERSION'] || Dpl::VERSION
      end
  end
end
