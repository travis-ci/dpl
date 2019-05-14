describe Dpl::Providers::CloudFoundry, fakefs: true do
  let(:args) { |e| %w(--api api.io --username name --password pass --organization org --space space) + args_from_description(e) }

  file 'manifest.yml'
  file 'other.yml'

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run %r(wget .*cli.run.pivotal.io.* -qO cf.tgz && tar -zxvf cf.tgz) }
    it { should have_run './cf api api.io' }
    it { should have_run './cf login -u name -p pass -o org -s space' }
    it { should have_run './cf push' }
    it { should have_run './cf logout' }
    it { should have_run_in_order }
  end

  describe 'given --app_name app_name' do
    it { should have_run './cf push "app_name"' }
  end

  describe 'given --manifest other.yml' do
    it { should have_run './cf push -f other.yml' }
  end
end

