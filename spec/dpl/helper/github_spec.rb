# frozen_string_literal: true

describe Dpl::Github do
  subject { described_class.normalize_filename(from) }

  strs = {
    '@': '@',
    '+': '+',
    '-': '-',
    '_': '_',
    'æ': 'ae',
    'ó': 'o',
    'ł': 'l',
    'ð': 'd',
    'ŋ': 'ng',
    'ż': 'z',
    '©': '.',
    '!': '.',
    '#': '.',
    '$': '.',
    '%': '.',
    '&': '.',
    "'": '.',
    '(': '.',
    ')': '.',
    ',': '.',
    '.': '.',
    ';': '.',
    '=': '.',
    '[': '.',
    '\\': '.',
    ']': '.',
    '^': '.',
    '`': '.',
    '{': '.',
    '}': '.',
    '~': '.',
  }

  strs.each do |from, to|
    describe from.to_s do
      let(:from) { from.to_s }

      it { is_expected.to eq to }
    end
  end
end
