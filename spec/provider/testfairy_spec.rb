require 'spec_helper'
require 'dpl/provider/testfairy'

describe DPL::Provider::TestFairy do

  before (:all) do
 
    @kyestore = '/tmp/debug.keystore'
    puts %x[curl -Lo #{@kyestore} https://github.com/giltsl/Ham/blob/master/out/debug.keystore?raw=true]
    puts %x[ls -lt #{@kyestore}]
    
    @local_android_app = '/tmp/android.apk'
    puts %x[curl -Lo #{@local_android_app} https://github.com/giltsl/Ham/blob/master/out/ham.apk?raw=true]
    puts %x[ls -lt #{@local_android_app}]
    
    @local_ios_app = '/tmp/ios.ipa'
    puts %x[curl -Lo #{@local_ios_app} https://github.com/giltsl/Ham/blob/master/out/Empty.ipa?raw=true]
    puts %x[ls -lt #{@local_ios_app }]
    
  end
  
  subject :provider do
    # the accoun is travis-test@testfairy.com
    described_class.new(DummyContext.new, :api_key => '4b85a2c03ba6026f4e22640a0432638180e1d1ea', :storepass => "android", :alias => "androiddebugkey", :keystore_file => @kyestore, :video => "true", :video_quality => 'low')  
  end


  describe "#check_auth" do
    example "check_auth without app_file" do
      lambda {provider.check_auth}.should raise_error
    end
    
    example "check_auth with app_file" do
      provider.options.update(:app_file => @local_android_app)
      provider.check_auth
    end
  end
  
  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end
  
  
  describe "#push_app" do
    example "push_app without app_file" do
      lambda {provider.push_app}.should raise_error
    end

    example "push_app with app_file" do
      provider.options.update(:app_file => @local_android_app)
      provider.push_app
    end
    
    example "push_app with wrong alias" do
      provider.options.update(:app_file => @local_android_app)
      provider.options.update(:alias => 'test')
      lambda {provider.push_app}.should raise_error
    end
    
    example "push_app with wrong storepass" do
      provider.options.update(:app_file => @local_android_app)
      provider.options.update(:storepass => 'test')
      lambda {provider.push_app}.should raise_error
    end
    
    example "push_app with iOS app_file" do
      provider.options.update(:app_file => @local_ios_app)
      provider.push_app
    end
  end
end
