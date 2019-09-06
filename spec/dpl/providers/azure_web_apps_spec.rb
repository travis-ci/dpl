describe Dpl::Providers::AzureWebApps do
  let(:args) { |e| %w(--site site --username name --password pass) + args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_run '[info] Committing changes to git' }
    it { should have_run '[info] $ git commit -m "Cleanup commit"' }
    it { should have_run 'git commit -m "Cleanup commit"' }
    it { should have_run '[info] Deploying to Azure Web App: site' }
    it { should have_run '[info] $ git push --force --quiet https://name:p*******************@site.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1' }
    it { should have_run 'git push --force --quiet https://name:pass@site.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1' }
  end

  describe 'given --slot slot' do
    it { should have_run 'git push --force --quiet https://name:pass@slot.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1' }
  end

  describe 'given --verbose' do
    it { should have_run 'git push --force --quiet https://name:pass@site.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master' }
  end

  describe 'given ENV vars', run: false do
    let(:args) { [] }

    env AZURE_WA_USERNAME: 'name',
        AZURE_WA_PASSWORD: 'pass',
        AZURE_WA_SITE: 'site',
        AZURE_WA_SLOT: 'slot'

    before { subject.run }

    it { should have_run 'git push --force --quiet https://name:pass@slot.scm.azurewebsites.net:443/site.git HEAD:refs/heads/master > /dev/null 2>&1' }
  end
end
