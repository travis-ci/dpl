# require 'spec_helper'
# require 'dpl/provider/gae'
#
# describe DPL::Provider::GAE do
#   subject :provider do
#     described_class.new(DummyContext.new, :user => 'foo', :password => 'bar')
#   end
#
#   let(:token) { 'deadbeef012345' }
#
#   describe '#push_app' do
#     example 'with default app_dir' do
#       provider.context.env['TRAVIS_BUILD_DIR'] = Dir.pwd
#       provider.options.update(:oauth_refresh_token => token)
#       expect(provider.context).to receive(:shell).with("#{DPL::Provider::GAE::APPCFG_BIN} --oauth2_refresh_token=#{token} update #{Dir.pwd}").and_return(true)
#       provider.push_app
#     end
#
#     example 'with custom app_dir' do
#       app_dir='foo'
#       provider.options.update(:oauth_refresh_token => token, :app_dir => app_dir)
#       expect(provider.context).to receive(:shell).with("#{DPL::Provider::GAE::APPCFG_BIN} --oauth2_refresh_token=#{token} update #{app_dir}").and_return(true)
#       provider.push_app
#     end
#   end
# end