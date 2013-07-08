require 'simplecov'

SimpleCov.start do
  coverage_dir '.coverage'

  add_filter "/spec/"
  add_group 'Library', 'lib'
end

class DummyContext
  def fold(message)
    yield
  end
end
