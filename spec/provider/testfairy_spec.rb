require 'spec_helper'
require 'dpl/provider/testfairy'

describe DPL::Provider::TestFairy do

  before (:all) do

    %x[mkdir /tmp/android/]
    %x[echo 'cp $3 $4' > /tmp/android/zipalign]
    %x[chmod +x /tmp/android/zipalign]

    @kyestore = '/tmp/debug.keystore'
    %x[curl -Lso #{@kyestore} http://www.testfairy.com/support-files/travis/dpl/debug.keystore]

    @local_android_app = '/tmp/android.apk'
    %x[curl -Lso #{@local_android_app} http://www.testfairy.com/support-files/travis/dpl/android.apk]

    @local_ios_app = '/tmp/ios.ipa'
    %x[curl -Lso #{@local_ios_app} http://www.testfairy.com/support-files/travis/dpl/Empty.ipa]

  end

  let :context do
    DummyContext.new
  end

  subject :provider do
    # the account is travis-test@testfairy.com
    described_class.new(context, :api_key => '4b85a2c03ba6026f4e22640a0432638180e1d1ea', :storepass => "android", :alias => "androiddebugkey", :keystore_file => @kyestore, :video => "true", :video_quality => 'low')
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
    before do
      context.stub(:env) { {'ANDROID_HOME' => '/tmp/android', 'JAVA_HOME' => '/usr/bin'} }
    end

    example "push_app without app_file" do
      lambda {provider.push_app}.should raise_error
    end

    xit "push_app with app_file" do
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

    example "push_app with notifify param" do
      provider.options.update(:app_file => @local_ios_app)
      provider.options.update(:notify => true)
      provider.push_app
    end
  end
end
