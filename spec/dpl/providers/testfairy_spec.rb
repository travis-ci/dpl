# frozen_string_literal: true

describe Dpl::Providers::Testfairy do
  let(:args) { |e| %w[--api_key key --app_file file] + args_from_description(e) }

  file 'file'

  before { stub_request(:post, 'https://upload.testfairy.com/api/upload').and_return(body: JSON.dump(status: 'success')) }
  before { |c| subject.run unless c.metadata[:example_group][:run].is_a?(FalseClass) }

  describe 'by default' do
    it { is_expected.to have_run(/Uploading to TestFairy:/) }
    it { is_expected.to have_run(/"apk_file": "file"/) }
  end

  describe 'given --symbols_file file' do
    it { is_expected.to have_run(/"symbols_file": "file"/) }
  end

  describe 'given --testers_groups one,two' do
    it { is_expected.to have_run(/"testers-groups": "one,two"/) }
  end

  describe 'given --notify' do
    it { is_expected.to have_run(/"notify": "on"/) }
  end

  describe 'given --auto_update' do
    it { is_expected.to have_run(/"auto-update": "on"/) }
  end

  describe 'given --advanced_options one,two' do
    it { is_expected.to have_run(/"advanced-options": "one,two"/) }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w[--app_file file] }

    env TESTFAIRY_API_KEY: 'key'
    it { expect { subject.run }.not_to raise_error }
  end
end
