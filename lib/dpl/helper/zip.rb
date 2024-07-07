# frozen_string_literal: true

require 'tempfile'

module Dpl
  class Zip < Struct.new(:src, :dest, :opts)
    ZIP_EXT = %w[.zip .jar].freeze

    def initialize(*)
      require 'zip'
      super
    end

    def zip
      if zip_file?
        File.new(src)
      elsif dir?
        zip_dir
      else
        zip_file
      end
    end

    def zip_dir
      create(Dir.glob(*glob).reject { |path| dir?(path) })
    end

    def zip_file
      create([src])
    end

    def create(files)
      ::Zip::File.open(dest, ::Zip::File::CREATE) do |zip|
        files.each do |file|
          zip.add(file.sub("#{src}/", ''), file)
        end
      end
      File.new(dest)
    end

    def zip_file?
      exts.include?(File.extname(src))
    end

    def dir?(path = src)
      File.directory?(path)
    end

    def copy
      FileUtils.cp(src, dest)
    end

    def glob
      glob = ["#{src}/**/*"]
      glob << File::FNM_DOTMATCH if dot_match?
      glob
    end

    def dot_match?
      opts[:dot_match]
    end

    def exts
      opts[:exts] ||= ZIP_EXT
    end

    def opts
      super || {}
    end
  end
end
