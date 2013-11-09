require 'simplecov'
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
end
