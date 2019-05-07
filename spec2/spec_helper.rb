require 'dpl2'
require 'support'
require 'webmock'

RSpec.configure do |c|
  c.include Support::Cl
  c.include Support::Ctx
  c.include Support::Env
  c.include Support::Matchers

  c.before { WebMock.disable_net_connect! }
end
