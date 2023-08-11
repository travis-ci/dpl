# frozen_string_literal: true

module Dpl
  module Transliterate
    APPROXIMATIONS = YAML.load(File.read(File.expand_path('../../../config/transliterate.yml', __dir__)))

    def transliterate(string, replacement = '.')
      string.gsub(/[^\x00-\x7f]/u) do |char|
        APPROXIMATIONS[char] || replacement
      end
    end
  end
end
