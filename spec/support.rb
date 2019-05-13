require 'support/cl'
require 'support/ctx'
require 'support/env'
require 'support/file'
require 'support/fixtures'
require 'support/matchers'
require 'support/memfs'

def symbolize(obj)
  case obj
  when Hash  then obj.map { |key, obj| [key.to_sym, symbolize(obj)] }.to_h
  when Array then obj.map { |obj| symbolize(obj) }
  else obj
  end
end
