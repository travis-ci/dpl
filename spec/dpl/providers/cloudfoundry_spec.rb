# frozen_string_literal: true

describe Dpl::Providers::Cloudfoundry do
  let(:args) { |e| %w[--username name --password pass --organization org --space space] + args_from_description(e) }

  file 'manifest.yml'
  file 'other.yml'

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { is_expected.to have_run(/wget .*cli.run.pivotal.io.* -qO cf.tgz && tar -zxvf cf.tgz/) }
    it { is_expected.to have_run './cf api https://api.run.pivotal.io' }
    it { is_expected.to have_run './cf login -u name -p pass -o org -s space' }
    it { is_expected.to have_run './cf push' }
    it { is_expected.to have_run './cf logout' }
    it { is_expected.to have_run_in_order }
  end

  describe 'given --api api.io' do
    it { is_expected.to have_run './cf api api.io' }
  end

  describe 'given --app_name app_name' do
    it { is_expected.to have_run './cf push "app_name"' }
  end

  describe 'given --manifest other.yml' do
    it { is_expected.to have_run './cf push -f other.yml' }
  end

  describe 'given --deployment_strategy rolling' do
    it { is_expected.to have_run './cf push --strategy rolling' }
  end

  describe 'given --v3' do
    it { is_expected.to have_run './cf v3-push' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w[--api api.io --organization org --space space] }

    env CLOUDFOUNDRY_USERNAME: 'name',
        CLOUDFOUNDRY_PASSWORD: 'password'

    it { expect { subject.run }.not_to raise_error }
  end
end
