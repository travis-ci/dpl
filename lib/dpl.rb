# frozen_string_literal: true

require 'dpl/cli'
require 'dpl/ctx'
require 'dpl/provider'
require 'dpl/version'
require 'dpl/string_ext'

module Dpl
  class Error < StandardError
    attr_reader :opts

    def initialize(msg, opts = {})
      super(msg)
      @opts = opts
      set_backtrace(opts[:backtrace]) if backtrace?
    end

    def backtrace?
      !!opts[:backtrace]
    end
  end
end
