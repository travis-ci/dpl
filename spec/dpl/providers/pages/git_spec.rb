describe Dpl::Providers::Pages do
  let(:args)    { |e| %w(--github_token token) + args_from_description(e) }
  let(:user)    { JSON.dump(login: 'login', name: 'name', email: 'email') }
  let(:headers) { { 'Content-Type': 'application/json', 'X-OAuth-Scopes': ['repo'] } }
  let(:home)    { File.expand_path('~') }
  let!(:cwd)    { File.expand_path('.') }
  let(:tmp)     { File.expand_path('tmp') }

  env FOO: 'foo',
      TRAVIS: true

  file 'key'

  before { stub_request(:get, 'https://api.github.com/user').and_return(status: 200, body: user, headers: headers) }
  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run '[info] Authenticated as login' }
    it { should have_run '[info] Configuring git committer to be author name (via Travis CI) <author email>' }
    it { should have_run '[info] Deploying branch gh-pages to github.com/travis-ci/dpl.git' }
    it { should have_run '[info] Cloning the branch gh-pages from the remote repo' }
    it { should have_run 'git clone --quiet --branch="gh-pages" --depth=1 "https://token@github.com/travis-ci/dpl.git" . > /dev/null 2>&1' }
    it { should have_run %(rsync -rl --exclude .git --delete "#{cwd}/" ".") }
    it { should have_run 'git config user.name "author name (via Travis CI)"' }
    it { should have_run 'git config user.email "author email"' }
    it { should have_run 'git add -A .' }
    it { should have_run 'git commit -q -m "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:gh-pages"' }
    it { should have_run 'git show --stat-count=10 HEAD' }
    it { should have_run '[info] Pushing to github.com/travis-ci/dpl.git' }
    it { should have_run 'git push --quiet "https://token@github.com/travis-ci/dpl.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
    it { should have_run_in_order }
  end

  describe 'given --verbose' do
    it { should have_run "[info] The source dir for deployment is #{cwd}" }
    it { should have_run '[info] Deploying branch gh-pages to github.com/travis-ci/dpl.git' }
    it { should have_run '[info] Using temporary work directory tmp' }
    it { should have_run "[info] Cloning the branch gh-pages from the remote repo" }
    it { should have_run "[info] Copying #{cwd} contents to ." }
    it { should have_run '[info] Configuring git committer to be author name (via Travis CI) <author email>' }
    it { should have_run '[info] Preparing to deploy gh-pages branch to gh-pages' }
    it { should have_run '[info] Pushing to github.com/travis-ci/dpl.git' }
  end

  describe 'given --repo other/name' do
    it { should have_run 'git commit -q -m "Deploy travis-ci/dpl to github.com/other/name.git:gh-pages"' }
    it { should have_run '[info] Pushing to github.com/other/name.git' }
    it { should have_run 'git push --quiet "https://token@github.com/other/name.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
  end

  describe 'given --target_branch other' do
    it { should have_run 'git commit -q -m "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:other"' }
    it { should have_run 'git push --quiet "https://token@github.com/travis-ci/dpl.git" "other":"other" > /dev/null 2>&1' }
  end

  describe 'given --no_keep_history' do
    it { should have_run '[info] Initializing local git repo' }
    it { should have_run 'git init .' }
    it { should have_run 'git checkout --orphan "gh-pages"' }
    it { should have_run %(rsync -rl --exclude .git --delete "#{cwd}/" ".") }
    it { should have_run 'git add -A .' }
    it { should have_run 'git commit -q -m "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:gh-pages"' }
    it { should have_run 'git show --stat-count=10 HEAD' }
    it { should have_run 'git push --force --quiet "https://token@github.com/travis-ci/dpl.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
  end

  describe 'given --no_keep_history --allow_empty' do
    it { should have_run 'git commit --allow-empty -q -m "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:gh-pages"' }
  end

  describe 'given --committer_from_gh' do
    it { should have_run 'git config user.name "name (via Travis CI)"' }
    it { should have_run 'git config user.email "email"' }
  end

  describe 'given --local_dir ./dir --verbose' do
    it { should have_run "rsync -rl --exclude .git --delete \"#{cwd}/dir/\" \".\"" }
    it { should have_run "[info] The source dir for deployment is #{cwd}/dir" }
    it { should have_run "[info] Copying #{cwd}/dir contents to ." }
  end

  describe 'given --target_dir ./dir --verbose' do
    it { should have_run "rsync -rl --exclude .git --delete \"#{cwd}/\" \"./dir\"" }
    it { should have_run "[info] The target dir for deployment is ./dir" }
    it { should have_run "[info] Copying #{cwd} contents to ./dir" }
  end

  describe 'given --fqdn fqdn.com' do
    it { should have_run 'echo "fqdn.com" > CNAME' }
  end

  describe 'given --project_name project_name' do
    it { should have_run 'git commit -q -m "Deploy project_name to github.com/travis-ci/dpl.git:gh-pages"' }
  end

  describe 'given project_name with a double quote' do
    let(:args) { |e| %w(--github_token token --project_name project"name) }
    it { should have_run 'git commit -q -m "Deploy project\"name to github.com/travis-ci/dpl.git:gh-pages"' }
  end

  describe 'given --name other' do
    it { should have_run 'git config user.name "other"' }
  end

  describe 'given --email other' do
    it { should have_run 'git config user.email "other"' }
  end

  describe 'given --commit_message "msg %{repo} %{$FOO}"' do
    it { should have_run 'git commit -q -m "msg travis-ci/dpl foo"' }
  end

  describe 'given --deploy_key ./key', record: true do
    let(:args) { |e| args_from_description(e) }
    it { should have_run '[info] Moving deploy key ./key to ~/.dpl/deploy_key' }
    it { should have_run '[info] Setting up git-ssh' }
    it { should have_run '[info] $ ssh -i ~/.dpl/deploy_key -T git@github.com 2>&1 | grep successful > /dev/null' }
    it { should have_run 'ssh -i ~/.dpl/deploy_key -T git@github.com 2>&1 | grep successful > /dev/null' }
    it { should have_run %r(cp .*lib/dpl/assets/git/detect_private_key .git/hooks/pre-commit) }
    it { should have_run 'git push --quiet "git@github.com:travis-ci/dpl.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
    it { should have_run_in_order }
  end

  describe 'working dir not dirty', run: false do
    before { allow(ctx).to receive(:git_dirty?).and_return false }
    before { subject.run }
    it { should have_run '[info] There are no changes to commit, stopping.' }
    it { should_not have_run /git commit / }
    it { should_not have_run /git push / }
  end

  describe 'with GITHUB credentials in env vars', run: false do
    let(:args) { %w(--strategy git) }
    env GITHUB_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end

  describe 'with PAGES credentials in env vars', run: false do
    let(:args) { %w(--strategy git) }
    env PAGES_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end
end
