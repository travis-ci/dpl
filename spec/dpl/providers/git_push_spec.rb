# frozen_string_literal: true

describe Dpl::Providers::GitPush do
  let(:args)    { |e| %W[--token token --branch #{branch}] + args_from_description(e) }
  let(:user)    { JSON.dump(login: 'login', name: 'name', email: 'email') }
  let(:headers) { { 'Content-Type': 'application/json', 'X-OAuth-Scopes': ['repo'] } }
  let(:home)    { File.expand_path('~') }
  let!(:cwd)    { File.expand_path('.') }
  let(:tmp)     { File.expand_path('tmp') }
  let(:api_url) { 'https://api.github.com/user' }
  let(:branch)  { 'other' }

  env FOO: 'foo',
      TRAVIS: true

  file 'key'

  before { stub_request(:get, api_url).and_return(status: 200, body: user, headers:) }
  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { is_expected.to have_run '[info] Authenticated as login' }
    it { is_expected.to have_run "[info] Source dir: #{cwd}, branch: other, base branch: master" }
    it { is_expected.to have_run '[info] Configuring git committer to be: name (via Travis CI) <email>' }
    it { is_expected.to have_run '[info] Cloning the branch other to tmp' }
    it { is_expected.to have_run 'git clone --quiet --branch="other" "https://token@github.com/travis-ci/dpl.git" . > /dev/null 2>&1' }
    it { is_expected.to have_run %(rsync -rl --exclude .git --delete "#{cwd}/" .) }
    it { is_expected.to have_run 'git config user.name "name (via Travis CI)"' }
    it { is_expected.to have_run 'git config user.email "email"' }
    it { is_expected.to have_run 'git add -A .' }
    it { is_expected.to have_run 'git commit -q -m "Update master"' }
    it { is_expected.to have_run 'git show --stat-count=10 HEAD' }
    it { is_expected.to have_run '[info] Pushing to github.com/travis-ci/dpl.git HEAD:other' }
    it { is_expected.to have_run 'git push --quiet "https://token@github.com/travis-ci/dpl.git" HEAD:"other" > /dev/null 2>&1' }
    it { is_expected.to have_run_in_order }
    it { expect(WebMock).to have_requested(:get, 'https://api.github.com/user').times(2) }
  end

  describe 'given the same branch as the current build branch', run: false do
    let(:branch) { 'git branch' }

    it { expect { subject.run }.to raise_error(/Prevented from pushing to the same branch as the current build branch/) }
  end

  describe 'given --repo other/name' do
    it { is_expected.to have_run '[info] Pushing to github.com/other/name.git HEAD:other' }
    it { is_expected.to have_run 'git push --quiet "https://token@github.com/other/name.git" HEAD:"other" > /dev/null 2>&1' }
  end

  describe 'given --allow_empty' do
    it { is_expected.to have_run 'git commit --allow-empty -q -m "Update master"' }
  end

  describe 'given --local_dir ./dir' do
    it { is_expected.to have_run "rsync -rl --exclude .git --delete \"#{cwd}/dir/\" ." }
    it { is_expected.to have_run "[info] Source dir: #{cwd}/dir, branch: other, base branch: master" }
    it { is_expected.to have_run "[info] Copying #{cwd}/dir contents to tmp" }
  end

  describe 'given --name other' do
    it { is_expected.to have_run 'git config user.name "other"' }
  end

  describe 'given --email other' do
    it { is_expected.to have_run 'git config user.email "other"' }
  end

  describe 'given --commit_message "msg %{repo} %{$FOO}"' do
    it { is_expected.to have_run 'git commit -q -m "msg travis-ci/dpl foo"' }
  end

  describe 'given --deploy_key ./key --name name --email email', record: true do
    let(:args) { |e| %w[--branch other] + args_from_description(e) }

    it { is_expected.to have_run '[info] Moving deploy key ./key to ~/.dpl/deploy_key' }
    it { is_expected.to have_run '[info] Setting up git-ssh' }
    it { is_expected.to have_run '[info] $ ssh -i ~/.dpl/deploy_key -T git@github.com 2>&1 | grep successful > /dev/null' }
    it { is_expected.to have_run 'ssh -i ~/.dpl/deploy_key -T git@github.com 2>&1 | grep successful > /dev/null' }
    it { is_expected.to have_run %r{cp .*lib/dpl/assets/git/detect_private_key .git/hooks/pre-commit} }
    it { is_expected.to have_run 'git push --quiet "git@github.com:travis-ci/dpl.git" HEAD:"other" > /dev/null 2>&1' }
    it { is_expected.to have_run_in_order }
  end

  describe 'given --pull_request', run: false do
    before do
      stub_request(:get, %r{repos/.*/pulls}).and_return(body: JSON.dump(prs), headers: { 'Content-Type': 'application/json' })
      stub_request(:post, %r{repos/.*/pulls}).and_return(body: JSON.dump(number: 1), headers: { 'Content-Type': 'application/json' })
      subject.run
    end

    context 'when pr does not exist' do
      let(:prs) { [] }
      let(:body) { JSON.dump(base: 'master', head: 'other', title: 'Update master') }

      it { is_expected.to have_run '[info] Pull request #1 created.' }
      it { expect(WebMock).to have_requested(:post, %r{repos/.*/pulls}).with(body:) }
    end

    context 'when pr exists' do
      let(:prs) { [head: { ref: 'other' }] }

      it { is_expected.to have_run '[info] Pull request exists.' }
      it { expect(WebMock).not_to have_requested(:post, %r{repos/.*/pulls}) }
    end
  end

  describe 'given --host other.com --name name --email email' do
    it { is_expected.not_to have_run(/Authenticated as/) }
    it { is_expected.to have_run 'git push --quiet "https://token@other.com/travis-ci/dpl.git" HEAD:"other" > /dev/null 2>&1' }
    it { expect(WebMock).not_to have_requested(:get, api_url) }
  end

  describe 'given --enterprise' do
    let(:api_url) { 'https://github.com/api/v3/user' }

    it { expect(WebMock).to have_requested(:get, api_url).times(2) }
  end

  describe 'given --enterprise --host other.com' do
    let(:api_url) { 'https://other.com/api/v3/user' }

    it { is_expected.to have_run '[info] Authenticated as login' }
    it { is_expected.to have_run 'git push --quiet "https://token@other.com/travis-ci/dpl.git" HEAD:"other" > /dev/null 2>&1' }
    it { expect(WebMock).to have_requested(:get, api_url).times(2) }
  end

  describe 'working dir not dirty', run: false do
    before do
      allow(ctx).to receive(:git_dirty?).and_return false
      subject.run
    end

    it { is_expected.to have_run '[info] There are no changes to commit, stopping.' }
    it { is_expected.not_to have_run(/git commit /) }
    it { is_expected.not_to have_run(/git push /) }
  end

  describe 'with GITHUB credentials in env vars', run: false do
    let(:args) { %w[--branch other] }

    env GITHUB_TOKEN: 'token'
    it { expect { subject.run }.not_to raise_error }
  end

  describe 'with GIT credentials in env vars', run: false do
    let(:args) { %w[--branch other] }

    env GIT_TOKEN: 'token'
    it { expect { subject.run }.not_to raise_error }
  end
end
