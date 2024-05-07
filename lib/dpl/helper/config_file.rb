# frozen_string_literal: true

module Dpl
  module ConfigFile
    def self.included(base)
      base.extend(ClassMethods)
    end

    # should this sit in Cl?
    module ClassMethods
      attr_reader :config_files

      def config(*paths)
        if paths.any?
          @config_files = paths
        elsif config_files
          paths = config_files.dup
          opts = paths.last.is_a?(Hash) ? paths.pop : {}
          conf = ConfigFiles.new(paths, opts).config
          known = self.opts.map(&:name).map(&:to_sym)
          conf.select { |key, _| known.include?(key) }
        else
          {}
        end
      end
    end

    class ConfigFiles < Struct.new(:paths, :opts)
      def config
        paths.map { |path| parse(path) }.inject(&:merge) || {}
      end

      def parse(path)
        str = File.exist?(path) ? File.read(path) : ''
        opts = str.lines.select { |line| line.include?('=') }.map(&:strip)
        opts = opts.map { |pair| pair.split('=', 2) }.to_h
        opts.transform_keys { |key| strip_prefix(key).to_sym }
      end

      def strip_prefix(str)
        opts[:prefix] ? str.sub(/^#{opts[:prefix]}[-_]?/, '') : str
      end
    end

    def opts
      @opts ||= self.class.config.merge(super)
    end
  end
end
