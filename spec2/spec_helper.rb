require 'dpl2'
require 'support'

RSpec.configure do |c|
  c.include Support::Cl
  c.include Support::Ctx
  c.include Support::Matchers
end
