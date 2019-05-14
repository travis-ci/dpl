describe Dpl::Providers::Testfairy do
  let(:args) { |e| %w(--api_key key --app_file file) + args_from_description(e) }

  chdir 'tmp'
  file 'file'

  before { stub_request(:post, 'http://api.testfairy.com/api/upload').and_return(body: JSON.dump(status: 'success')) }
  before { subject.run }

  describe 'by default' do
    it { should have_run /Uploading to TestFairy:/ }
    it { should have_run /"apk_file": "file"/ }
    it { should have_run /"video": "on"/ }
    it { should have_run /"video-quality": "high"/ }
    it { should have_run /"max-duration": "10m"/ }
  end

  describe 'given --symbols_file file' do
    it { should have_run /"symbols_file": "file"/ }
  end

  describe 'given --testers_groups one,two' do
    it { should have_run /"testers-groups": "one,two"/ }
  end

  describe 'given --notify' do
    it { should have_run /"notify": "on"/ }
  end

  describe 'given --auto_update' do
    it { should have_run /"auto-update": "on"/ }
  end

  describe 'given --video_quality low' do
    it { should have_run /"video-quality": "low"/ }
  end

  describe 'given --screenshot_interval 1' do
    it { should have_run /"screenshot-interval": 1/ }
  end

  describe 'given --max_duration 1m' do
    it { should have_run /"max-duration": "1m"/ }
  end

  describe 'given --advanced_options one,two' do
    it { should have_run /"advanced-options": "one,two"/ }
  end

  describe 'given --data_only_wifi' do
    it { should have_run /"data-only-wifi": "on"/ }
  end

  describe 'given --record_on_background' do
    it { should have_run /"record-on-background": "on"/ }
  end

  describe 'given --icon_watermark' do
    it { should have_run /"icon-watermark": "on"/ }
  end

  describe 'given --metrics one,two' do
    it { should have_run /"metrics": "one,two"/ }
  end
end
