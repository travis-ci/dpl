# frozen_string_literal: true

class Version
  InvalidVersion = Class.new(ArgumentError)
  InvalidRequire = Class.new(ArgumentError)

  MSGS = {
    version: 'Unable to parse version: %p',
    require: 'Unable to parse requirement: %p'
  }.freeze

  VERSION = /^(\d+)(?:\.(\d+))?(?:\.(\d+))?$/
  REQUIRE = /^(~>|>|>=|=|!=|<=|<) (\d+(?:\.\d+)?(?:\.\d+)?)$/

  include Comparable

  def initialize(str)
    @nums = split(str) || raise(InvalidVersion, MSGS[:version] % str)
  end

  def satisfies?(str)
    send(*parse(str) || raise(InvalidRequire, MSGS[:require] % str))
  end

  def size
    nums.size
  end

  def to_a
    nums
  end

  def to_s
    nums.join('.')
  end

  def ==(other)
    trunc(other.size).to_a == other.to_a
  end

  def !=(other)
    trunc(other.size).to_a != other.to_a
  end

  def <=>(other)
    to_a <=> other.to_a
  end

  define_method :'~>' do |min|
    min = min.trunc(nums.size)
    max = min.clone.bump
    self >= min && self < max
  end

  def bump
    ix = nums[1] ? -2 : -1
    nums[ix] = nums[ix] + 1
    nums[-1] = nums[-1] = 0 if nums[1]
    self
  end

  def trunc(size)
    @nums = nums[0..size - 1]
    self
  end

  def clone
    Version.new(to_s)
  end

  private

  attr_reader :nums

  def split(str)
    str =~ VERSION && [::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3)].compact.map(&:to_i)
  end

  def parse(str)
    op, version = str =~ REQUIRE && [::Regexp.last_match(1), ::Regexp.last_match(2)]
    op = '==' if op == '='
    [op, Version.new(version)] if op
  end
end
