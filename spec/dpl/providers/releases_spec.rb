describe Dpl::Providers::Releases do
  let(:args)     { |e| %w(--api_key key) + args_from_description(e) }
  let(:headers)  { { 'Content-Type': 'application/json', 'X-OAuth-Scopes': ['repo'] } }
  let(:user)     { JSON.dump(login: 'login', name: 'name', email: 'email') }
  let(:releases) { JSON.dump([tag_name: 'tag', url: '/releases/1']) }
  let(:release)  { JSON.dump(tag_name: 'tag', url: '/releases/1', assets_url: '/releases/1/assets', upload_url: '/releases/1/assets{?name,label}') }
  let(:assets)   { JSON.dump([]) }

  file 'one'
  file 'one_two'
  file 'two'

  before { stub_request(:get, %r(/user$)).and_return(status: 200, body: user, headers: headers) }
  before { stub_request(:get, %r(/releases\?)).and_return(status: 200, body: releases, headers: headers) }
  before { stub_request(:get, %r(/releases/1$)).and_return(status: 200, body: release, headers: headers) }
  before { stub_request(:get, %r(/releases/1/assets\?)).and_return(status: 200, body: assets, headers: headers) }
  before { stub_request(:patch, %r(/releases/1$)) }
  before { stub_request(:post, %r(/releases/1/assets\?)) }
  before { stub_request(:delete, %r(/releases/1/assets/1$)) }
  before { |c| subject.run if run?(c) }

  let(:repo)     { 'travis-ci/dpl' }
  let(:tag_name) { 'tag' }
  let(:name_)    { nil }
  let(:draft)    { false }
  let(:prerelease) { nil }
  let(:release_number) { nil }
  let(:release_notes) { nil }
  let(:target_commitish) { 'sha' }

  matcher :release_json do
    match do |body|
      expect(symbolize(JSON.parse(body))).to include(compact(
        repo: repo,
        name: name_,
        tag_name: tag_name,
        target_commitish: target_commitish,
        release_number: release_number,
        body: release_notes,
        prerelease: prerelease,
        draft: draft,
      ))
    end
  end

  describe 'by default', record: true do
    it { should have_run '[info] Authenticated as login' }
    it { should have_run '[info] Deploying to repo: travis-ci/dpl' }
    it { should have_run 'git fetch --tags' }
    it { should have_run '[info] Current tag is: tag' }
    it { should have_run '[info] Setting tag_name to tag' }
    it { should have_run '[info] Setting target_commitish to sha' }
    it { should have_run_in_order }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
    it { should have_requested(:post, %r(/releases/1/assets\?name=one$)) }
  end

  describe 'asset exists' do
    let(:assets) { JSON.dump([name: 'one', url: '/releases/1/assets/1']) }
    it { should have_run '[info] File one already exists, skipping.' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
    it { should_not have_requested(:delete, %r(/releases/1/assets/1)) }
    it { should_not have_requested(:post, %r(/releases/1/assets\?name=one$)) }
  end

  describe 'asset exists, given --overwrite' do
    let(:assets) { JSON.dump([name: 'one', url: '/releases/1/assets/1']) }
    it { should have_run '[info] File one already exists, overwriting.' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
    it { should have_requested(:delete, %r(/releases/1/assets/1)) }
    it { should have_requested(:post, %r(/releases/1/assets\?name=one$)) }
  end

  describe 'given --repo other/name' do
    let(:repo) { 'other/name' }
    let(:target_commitish) { nil }
    it { should have_run '[info] Deploying to repo: other/name' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --file one*' do
    it { should have_requested(:post, %r(/releases/1/assets\?name=one$)) }
    it { should have_requested(:post, %r(/releases/1/assets\?name=one_two$)) }
  end

  describe 'given --file one* --no-file_glob', run: false do
    file 'one*'
    before { subject.run }
    it { should have_requested(:post, %r(/releases/1/assets\?name=one\.$)) }
    it { should_not have_requested(:post, %r(/releases/1/assets\?name=one*$)) }
  end

  describe 'given --prerelease' do
    let(:prerelease) { true }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --release_number 1' do
    let(:release_number) { '1' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --draft' do
    let(:tag_name) { nil }
    let(:draft) { true }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --tag_name other' do
    let(:tag_name) { 'other' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --target_commitish other' do
    let(:target_commitish) { 'other' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --name name' do
    let(:name_) { 'name' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --release_notes release_notes' do
    let(:release_notes) { 'release_notes' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'given --release_notes_file ./release_notes', run: false do
    let(:release_notes) { 'release_notes' }
    file './release_notes', 'release_notes'
    before { subject.run }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'missing release notes file, given --release_notes_file ./release_notes', run: false do
    let(:release_notes) { 'release_notes' }
    it { expect { subject.run }.to raise_error('File ./release_notes does not exist.') }
  end

  describe 'given --body body' do
    let(:release_notes) { 'body' }
    it { should have_requested(:patch, %r(/releases/1)).with(body: release_json) }
  end

  describe 'with GITHUB credentials in env vars', run: false do
    let(:args) { [] }
    env GITHUB_TOKEN: 'key'
    it { expect { subject.run }.to_not raise_error }
  end

  describe 'with GITHUB credentials in env vars (alias)', run: false do
    let(:args) { [] }
    env GITHUB_API_KEY: 'key'
    it { expect { subject.run }.to_not raise_error }
  end

  describe 'with RELEASES credentials in env vars', run: false do
    let(:args) { [] }
    env RELEASES_TOKEN: 'key'
    it { expect { subject.run }.to_not raise_error }
  end

  describe 'with RELEASES credentials in env vars (alias)', run: false do
    let(:args) { [] }
    env RELEASES_API_KEY: 'key'
    it { expect { subject.run }.to_not raise_error }
  end

  def compact(hash)
    hash.reject { |_, value| value.nil? }.to_h
  end
end
