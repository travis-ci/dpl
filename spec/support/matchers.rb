require 'support/matchers/have_deprecated'
require 'support/matchers/have_env'
require 'support/matchers/have_logged'
require 'support/matchers/have_netrc'
require 'support/matchers/have_run'
require 'support/matchers/have_written'


module Support
  module Matchers
    def self.included(base)
      base.before(:context) { HaveRun.cmds.clear }
    end
  end
end
