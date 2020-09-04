describe Dpl::Providers::Datica do
  let(:args) { |e| %w(--target target) + args_from_description(e) }

  env TRAVIS_REPO_SLUG: 'repo',
      TRAVIS_BRANCH: 'branch',
      TRAVIS_BUILD_NUMBER: '1',
      TRAVIS_COMMIT: 'commit'

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_run 'git checkout HEAD' }
    it { should have_run 'git add . --all --force' }
    it { should have_run 'git commit -m "Build #1 (commit) of repo@branch" --quiet' }
    it { should have_run 'git push --force target HEAD:master' }
  end

  describe 'using alias registry key :catalyze', run: false do
    let(:provider) { :catalyze }
    before { subject.run }
    it { should have_run 'git push --force target HEAD:master' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }
    env DATICA_TARGET: 'target'
    it { expect { subject.run }.to_not raise_error }
  end
end
