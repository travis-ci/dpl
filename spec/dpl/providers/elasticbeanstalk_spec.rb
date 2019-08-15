describe Dpl::Providers::Elasticbeanstalk do
  let(:args) { |e| required + args_from_description(e) }
  let(:required) { %w(--access_key_id id --secret_access_key key --env env --bucket bucket) }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }
  let(:events) { [] }

  matcher :create_app_version do |opts = {}|
    match do |*|
      next false unless requests[:create_application_version].any?
      next true unless opts[:with]
      body = requests[:create_application_version][0].body.read
      opts[:with].is_a?(Regexp) ? body =~ opts[:with] : body.include?(opts[:with])
    end
  end

  matcher :update_environment do
    match do
      requests[:update_environment].any?
    end
  end

  before do
    Aws.config[:s3] = {
      stub_responses: {
      }
    }
    Aws.config[:elasticbeanstalk] = {
      stub_responses: {
        create_application_version: ->(ctx) {
          requests[:create_application_version] << ctx.http_request
          {
            application_version: {
              version_label: 'label'
            }
          }
        },
        update_environment: ->(ctx) {
          requests[:update_environment] << ctx.http_request
        },
        describe_environments: {
          environments: [
            status: 'Ready'
          ]
        },
        describe_events: {
          events: events
        }
      }
    }
  end

  after { Aws.config.clear }

  file 'one'
  file 'two'

  describe 'by default' do
    before { subject.run }
    it { expect(File.exist?(subject.archive_name)).to be true }
    it { should have_run '[info] Using Access Key: i*******************' }
    it { should create_app_version with: 'ApplicationName=dpl' }
    it { should create_app_version with: 'Description=commit%20msg' }
    it { should create_app_version with: 'S3Bucket=bucket' }
    it { should create_app_version with: /S3Key=travis-sha-.*.zip/ }
    it { should create_app_version with: /VersionLabel=travis-sha.*/ }
    it { should update_environment }
  end

  describe 'given --bucket_path one/two' do
    before { subject.run }
    it { should create_app_version with: /S3Key=one%2Ftwo%2Ftravis-sha-.*.zip/ }
  end

  describe 'given --only_create_app_version' do
    before { subject.run }
    it { should create_app_version }
    it { should_not update_environment }
  end

  describe 'given --zip_file other.zip' do
    before { subject.run }
    it { expect(File.exist?('other.zip')).to be true }
    it { should create_app_version with: /S3Key=travis-sha-.*.zip/ }
  end

  describe 'given --wait_until_deployed' do
    let(:events) { [event_date: Time.now, severity: 'ERROR', message: 'msg'] }
    it { expect { subject.run }.to raise_error /Deployment failed/ }
  end

  describe 'with ~/.aws/credentials' do
    let(:args) { |e| %w(--env env --bucket_name bucket) }

    file '~/.aws/credentials', <<-str.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    str

    before { subject.run }
    it { should have_run '[info] Using Access Key: ac******************' }
  end

  describe 'with ~/.aws/config' do
    let(:args) { |e| %w(--access_key_id id --secret_access_key secret) }

    file '~/.aws/config', <<-str.sub(/^\s*/, '')
      [default]
      env=env
      bucket=bucket
    str

    before { subject.run }
    it { should create_app_version with: 'S3Bucket=bucket' }
  end
end
