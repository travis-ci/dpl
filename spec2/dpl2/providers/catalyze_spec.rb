describe Dpl::Providers::Catalyze do
  let(:args) { |e| %w(--target target) + args_from_description(e) }

  describe 'by default' do
    before { subject.run }
    it { should have_run 'git push --force target HEAD:master' }
  end

  describe 'given --skip-cleanup' do
    env TRAVIS_REPO_SLUG: 'repo',
        TRAVIS_BRANCH: 'branch',
        TRAVIS_BUILD_NUMBER: '1',
        TRAVIS_COMMIT: 'commit'

    before { subject.run }

    it { should have_run 'git checkout HEAD' }
    it { should have_run 'git add . --all --force' }
    it { should have_run 'git commit -m "Build #1 (commit) of repo@branch" --quiet' }
  end
end
