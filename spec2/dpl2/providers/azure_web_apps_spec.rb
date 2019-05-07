describe Dpl::Providers::AzureWebApps do
  describe 'not using env vars' do
    let(:args) { |e| %w(--site site --username name --password pass) + args_from_description(e) }

    before { subject.run }

    describe 'by default' do
      it { should have_run "git push --force --quiet https://name:pass@site.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1" }
    end

    describe 'given --slot slot' do
      it { should have_run "git push --force --quiet https://name:pass@slot.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1" }
    end

    describe 'given --verbose' do
      it { should have_run "git push --force --quiet https://name:pass@site.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master" }
    end

    describe 'given --skip-cleanup' do
      it { should have_run 'git checkout HEAD' }
      it { should have_run 'git add . --all --force' }
      it { should have_run 'git commit -m "Skip cleanup commit"' }
    end
  end

  describe 'given ENV vars' do
    env AZURE_WA_USERNAME: 'name',
        AZURE_WA_PASSWORD: 'pass',
        AZURE_WA_SITE: 'site',
        AZURE_WA_SLOT: 'slot'

    before { subject.run }

    it { should have_run "git push --force --quiet https://name:pass@slot.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1" }
  end
end
