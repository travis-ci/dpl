describe Dpl::Providers::Now do
  let(:args) { |e| %w(--token secret) + args_from_description(e) }
  let(:cwd)  { Dir.pwd }

  before { ctx.stdout[:deploy] = 'https://deployment.url' }
  before { subject.run }

  describe 'by default', record: true do
    it { should have_run %([info] Deploying #{cwd} on now.sh ...) }
    it { should have_run %([info] $ now --token="s*******************" --name="dpl" --no-clipboard #{cwd}) }
    it { should have_run %(now --token="secret" --name="dpl" --no-clipboard #{cwd}) }
    it { should have_run_in_order }
  end

  describe 'given --name other' do
    it { should have_run %(now --token="secret" --name="other" --no-clipboard #{cwd}) }
  end

  describe 'given --type docker' do
    it { should have_run %(now --token="secret" --name="dpl" --no-clipboard --docker #{cwd}) }
  end

  describe 'given --dir ./dir' do
    it { should have_run %(now --token="secret" --name="dpl" --no-clipboard #{cwd}/dir) }
  end

  describe 'given --team team' do
    it { should have_run %(now --token="secret" --team="team" --name="dpl" --no-clipboard #{cwd}) }
  end

  describe 'given --alias alias' do
    it { should have_run '[info] Assigning alias alias to https://deployment.url ...' }
    it { should have_run '[info] $ now alias --token="s*******************" https://deployment.url alias' }
    it { should have_run 'now alias --token="secret" https://deployment.url alias' }
  end

  describe 'given --alias alias --rm' do
    it { should have_run '[info] Cleaning up old deployments ...' }
    it { should have_run '[info] $ now rm --safe --yes --token="s*******************" alias' }
    it { should have_run 'now rm --safe --yes --token="secret" alias' }
  end

  describe 'given --rules_domain domain' do
    it { should have_run 'now alias --token="secret" domain -r rules.json' }
  end

  describe 'given --rules_domain domain --rules_file other.json' do
    it { should have_run 'now alias --token="secret" domain -r other.json' }
  end

  describe 'given --scale 2' do
    it { should have_run '[info] Scaling to 2 ...' }
    it { should have_run '[info] $ now scale --token="s*******************" https://deployment.url 2' }
    it { should have_run 'now scale --token="secret" https://deployment.url 2' }
  end
end
