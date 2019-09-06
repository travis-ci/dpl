describe Dpl::Providers::Boxfuse do
  let(:args) { |e| %w(--user user --secret 1234) + args_from_description(e) }
  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_run %r(curl -L https://files.boxfuse.com/.*.tar.gz | tar xz) }
    it { should have_run '[info] $ boxfuse/boxfuse run -user="user" -secret="1*******************"' }
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234"' }
  end

  describe 'given --config_file ./file' do
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234" -configfile=./file' }
  end

  describe 'given --configfile ./file' do
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234" -configfile=./file' }
    it { should have_deprecated :configfile }
  end

  describe 'given --payload payload' do
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234" -payload="payload"' }
  end

  describe 'given --app app' do
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234" -app="app"' }
  end

  describe 'given --env env' do
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234" -env="env"' }
  end

  describe 'given --extra_args args' do
    it { should have_run 'boxfuse/boxfuse run -user="user" -secret="1234" args' }
  end

  describe 'with credentials in env vars', run: false do
    env BOXFUSE_USER: 'user',
        BOXFUSE_SECRET: '1234'

    it { expect { subject.run }.to_not raise_error }
  end
end
