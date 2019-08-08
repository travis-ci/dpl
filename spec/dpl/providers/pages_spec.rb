describe Dpl::Providers::Pages do
  let(:args)    { |e| %w(--github_token token) + args_from_description(e) }
  let(:user)    { JSON.dump(login: 'login', name: 'name', email: 'email') }
  let(:headers) { { 'Content-Type': 'application/json', 'X-OAuth-Scopes': ['repo'] } }
  let!(:cwd)    { File.expand_path('.') }
  let(:tmp)     { File.expand_path('tmp') }

  before { stub_request(:get, 'https://api.github.com/user').and_return(status: 200, body: user, headers: headers) }

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[info] Logged in as login (name)' }
    it { should have_run '[info] Deploying branch gh-pages to github.com' }
    it { should have_run '[info] Cloning the branch gh-pages from the remote repo' }
    it { should have_run 'git clone --quiet --branch="gh-pages" --depth=1 "https://token@github.com/travis-ci/dpl.git" . > /dev/null 2>&1' }
    it { should have_run %(rsync -rl --exclude .git --delete "#{cwd}/" .) }
    it { should have_run 'git config user.name "Deploy Bot (from Travis CI)"' }
    it { should have_run 'git config user.email "deploy@travis-ci.org"' }
    it { should have_run 'git add -A .' }
    it { should have_run 'git commit -qm "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:gh-pages"' }
    it { should have_run 'git show --stat-count=10 HEAD' }
    it { should have_run '[info] Pushing to github.com/travis-ci/dpl.git' }
    it { should have_run 'git push --quiet "https://token@github.com/travis-ci/dpl.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
    it { should have_run_in_order }
  end

  describe 'given --verbose' do
    it { should have_run "[info] The source dir for deployment is #{cwd}" }
    it { should have_run '[info] Deploying branch gh-pages to github.com' }
    it { should have_run '[info] Using temporary work directory tmp' }
    it { should have_run "[info] Cloning the branch gh-pages from the remote repo" }
    it { should have_run "[info] Copying #{cwd} contents to tmp" }
    it { should have_run '[info] Configuring git committer to be Deploy Bot (from Travis CI) <deploy@travis-ci.org>' }
    it { should have_run '[info] Preparing to deploy gh-pages branch to gh-pages' }
    it { should have_run '[info] Pushing to github.com/travis-ci/dpl.git' }
  end

  describe 'given --repo other/name' do
    it { should have_run 'git commit -qm "Deploy travis-ci/dpl to github.com/other/name.git:gh-pages"' }
    it { should have_run '[info] Pushing to github.com/other/name.git' }
    it { should have_run 'git push --quiet "https://token@github.com/other/name.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
  end

  describe 'given --target_branch other' do
    it { should have_run 'git commit -qm "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:other"' }
    it { should have_run 'git push --quiet "https://token@github.com/travis-ci/dpl.git" "other":"other" > /dev/null 2>&1' }
  end

  describe 'given --no_keep_history' do
    it { should have_run '[info] Initializing local git repo' }
    it { should have_run 'git init .' }
    it { should have_run 'git checkout --orphan "gh-pages"' }
    it { should have_run %(rsync -rl --exclude .git --delete "#{cwd}/" .) }
    it { should have_run 'git add -A .' }
    it { should have_run 'git commit -qm "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:gh-pages"' }
    it { should have_run 'git show --stat-count=10 HEAD' }
    it { should have_run 'git push --force --quiet "https://token@github.com/travis-ci/dpl.git" "gh-pages":"gh-pages" > /dev/null 2>&1' }
  end

  describe 'given --no_keep_history --allow_empty' do
    it { should have_run 'git commit --allow-empty -qm "Deploy travis-ci/dpl to github.com/travis-ci/dpl.git:gh-pages"' }
  end

  describe 'given --committer_from_gh' do
    it { should have_run 'git config user.name "name"' }
    it { should have_run 'git config user.email "email"' }
  end

  describe 'given --local_dir ./dir --verbose' do
    it { should have_run "rsync -rl --exclude .git --delete \"#{cwd}/dir/\" ." }
    it { should have_run "[info] The source dir for deployment is #{cwd}/dir" }
    it { should have_run "[info] Copying #{cwd}/dir contents to tmp" }
  end

  describe 'given --fqdn fqdn.com' do
    it { should have_run 'echo "fqdn.com" > CNAME' }
  end

  describe 'given --project_name project_name' do
    it { should have_run 'git commit -qm "Deploy project_name to github.com/travis-ci/dpl.git:gh-pages"' }
  end

  describe 'given --name other' do
    it { should have_run 'git config user.name "other (from Travis CI)"' }
  end

  describe 'given --email other' do
    it { should have_run 'git config user.email "other"' }
  end
end
