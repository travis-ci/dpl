require 'fileutils'

module Dpl
  module Assets
    class Asset < Struct.new(:provider, :namespace, :name)
      include FileUtils

      DIR = File.expand_path('../../assets', __FILE__)

      def copy(target)
        cp path, File.expand_path(target)
      end

      def read
        exists? ? provider.interpolate(File.read(path)) : unknown
      end

      def exists?
        File.exists?(path)
      end

      def unknown
        raise "Could not find asset #{path}"
      end

      def path
        "#{DIR}/#{namespace}/#{name}"
      end
    end

    def asset(*args)
      name, namespace = args.reverse
      Asset.new(self, namespace || registry_key, name)
    end
  end
end
