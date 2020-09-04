describe Dpl::Providers::Flynn do
  let(:args) { %w(--git https://flynn.io/target.git) }

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run %r(git config user.email) }
    it { should have_run %r(git config user.name) }
    it { should have_run 'git fetch origin $TRAVIS_BRANCH --unshallow' }
    it { should have_run 'git push https://flynn.io/target.git HEAD:refs/heads/master -f' }
    it { should have_run_in_order }
  end
end
