# frozen_string_literal: true

require 'dpl/helper/transliterate'

# I18n.load_path << File.expand_path('config/transliterate.yml')
# I18n.eager_load!
# I18n.config.available_locales_set << :en # seems really wrong, but ¯\_(ツ)_/¯

module Dpl
  module Github
    include Transliterate

    def normalize_filename(str)
      str = File.basename(str)
      str = str.split(' ').first
      str = transliterate(str)
      str.gsub(/[^\w@+\-_]/, '.')
    end

    extend self
  end
end
