require 'spec_helper'
require 'dpl/provider/testfairy'

describe DPL::Provider::TestFairy do

  before (:all) do

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
    described_class.new(context, :api_key => '4b85a2c03ba6026f4e22640a0432638180e1d1ea', :video => "true", :video_quality => 'low')
  end


  describe "#check_auth" do
    
    example "check_auth without app_file" do
      expect {provider.check_auth}.to raise_error("App file is missing")
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
      expect {provider.check_auth }.to raise_error("App file is missing")
    end

    example "push_app with app_file" do
      provider.options.update(:app_file => @local_android_app)
      provider.push_app
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
