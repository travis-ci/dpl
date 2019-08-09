require 'dpl/cli'
require 'dpl/ctx'
require 'dpl/provider'
require 'dpl/version'

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
