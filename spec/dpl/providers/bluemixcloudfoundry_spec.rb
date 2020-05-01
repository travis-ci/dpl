describe Dpl::Providers::Bluemixcloudfoundry do
  let(:args) { |e| %w(--username name --password pass --organization org --space space) + args_from_description(e) }

  file 'manifest.yml'
  file 'other.yml'

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run %r(wget .*cli.run.pivotal.io.* -qO cf.tgz && tar -zxvf cf.tgz) }
    it { should have_run './cf api api.ng.bluemix.net' }
    it { should have_run './cf login -u name -p pass -o "org" -s "space"' }
    it { should have_run './cf target -o "org" -s "space"' }
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

  describe 'given --api api.io' do
    it { should have_run './cf api api.io' }
  end

  describe 'given --region ng' do
    it { should have_run './cf api api.ng.bluemix.net' }
  end

  describe 'given --region ng' do
    it { should have_run './cf api api.ng.bluemix.net' }
  end

  describe 'given --region eu-gb' do
    it { should have_run './cf api api.eu-gb.bluemix.net' }
  end

  describe 'given --region eu-de' do
    it { should have_run './cf api api.eu-de.bluemix.net' }
  end

  describe 'given --region au-syd' do
    it { should have_run './cf api api.au-syd.bluemix.net' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--organization org --space space) }

    env CLOUDFOUNDRY_USERNAME: 'name',
        CLOUDFOUNDRY_PASSWORD: 'password'

    it { expect { subject.run }.to_not raise_error }
  end
end
