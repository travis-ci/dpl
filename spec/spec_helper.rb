require 'json/pure'
require 'dpl/error'
require 'dpl/provider'
require 'rspec/its'
require 'coveralls'

Coveralls.wear!

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
