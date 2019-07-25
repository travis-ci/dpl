# frozen_string_literal: true

require 'rack'
app = ->(env) { [200, { 'Content-type' => 'text/plain' }, ['%{ID}']] }
Rack::Handler::WEBrick.run(app, Host: '0.0.0.0', Port: '3000')
