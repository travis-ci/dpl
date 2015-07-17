require 'simplecov'
require 'dpl/error'
require 'dpl/provider'
require 'rspec/its'
require 'coveralls'

Coveralls.wear!

SimpleCov.start do
  coverage_dir '.coverage'

  add_filter "/spec/"
  add_group 'Library', 'lib'
end

class DummyContext
  def shell(command)
  end

  def fold(message)
    yield
  end

  def env
    @env ||= {}
  end
end
