describe Dpl::Providers::Hephy do
  let(:args) { |e| %w(--controller hephy.hephyapps.com --username user --password pass) + args_from_description(e) }

  chdir 'tmp'

  before { subject.run }

  describe 'by default' do
    it { should have_run 'curl -sSL https://raw.githubusercontent.com/teamhephy/workflow-cli/master/install-v2.sh | bash -x -s stable' }
    it { should have_run './deis keys:add .dpl/id_rsa.pub' }
    it { should have_run %r(dpl/.dpl/git-ssh hephy-builder.hephyapps.com -p 2222  2>&1 | grep -c 'PTY allocation request failed' > /dev/null) }
    it { should have_run './deis login hephy.hephyapps.com --username=user --password=pass' }
    it { should have_run 'mv ./deis ~/deis' }
    it { should have_run 'git stash --all' }
    it { should have_run 'mv ~/deis ./deis' }
    it { should have_run %r(git push.*ssh://git@hephy-builder.hephyapps.com:2222/dpl.git) }
    it { should have_run "./deis keys:remove machine_name" }
    it { should have_run 'git stash pop' }
    it { should have_run_in_order }
  end

  describe 'given --cli_version v2.7.0' do
    it { should have_run %r(curl -sSL https://.*install-v2.sh | bash -x -s v2.7.0) }
  end

  describe 'given --verbose' do
    it { should have_run %r(git push -v ssh://git@hephy-builder.hephyapps.com:2222/dpl.git) }
  end
end
