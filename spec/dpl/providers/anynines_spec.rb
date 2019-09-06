describe Dpl::Providers::Anynines do
  let(:args) { |e| %w(--username name --password pass --organization org --space space) + args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    # it { should have_run %r(wget .*cli.run.pivotal.io.* -qO cf.tgz && tar -zxvf cf.tgz) }
    it { should have_run './cf api https://api.de.a9s.eu' }
    it { should have_run '[info] $ ./cf login -u name -p p******************* -o org -s space' }
    it { should have_run './cf login -u name -p pass -o org -s space' }
    it { should have_run './cf push' }
    it { should have_run '[info] $ ./cf logout' }
    it { should have_run './cf logout' }
    it { should have_run_in_order }
  end

  describe 'given --app_name app_name' do
    it { should have_run './cf push "app_name"' }
  end

  describe 'given --manifest manifest' do
    it { should have_run './cf push -f manifest' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--organization org --space space) }

    env ANYNINES_USERNAME: 'name',
        ANYNINES_PASSWORD: 'password'

    it { expect { subject.run }.to_not raise_error }
  end
end
