describe Dpl::Providers::Hackage do
  let(:args) { |e| %w(--username user --password pass) + args_from_description(e) }

  file 'dist/one.tar.gz'
  file 'dist/two.tar.gz'

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[apt:get] cabal (cabal-install)' }
    it { should have_run 'cabal check' }
    it { should have_run 'cabal sdist' }
    it { should have_run 'cabal upload --username="user" --password="pass" dist/one.tar.gz' }
    it { should have_run 'cabal upload --username="user" --password="pass" dist/two.tar.gz' }
    it { should have_run_in_order }
  end
end
