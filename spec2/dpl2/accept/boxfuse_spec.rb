describe Dpl::Provider::Boxfuse, 'acceptance' do
  before { subject.run }

  describe 'install' do
    it { should have_run %r(curl -L https://files.boxfuse.com/.*.tar.gz | tar xz) }
  end

  describe 'by default' do
    it { should have_run 'boxfuse/boxfuse run' }
  end

  describe 'given --user user' do
    it { should have_run 'boxfuse/boxfuse run --user=user' }
  end

  describe 'given --secret secret' do
    it { should have_run 'boxfuse/boxfuse run --secret=secret' }
  end

  describe 'given --config_file ./file' do
    it { should have_run 'boxfuse/boxfuse run --configfile=./file' }
  end

  describe 'given --configfile ./file' do
    it { should have_run 'boxfuse/boxfuse run --configfile=./file' }
    it { should have_deprecated :configfile }
  end

  describe 'given --payload payload' do
    it { should have_run 'boxfuse/boxfuse run --payload=payload' }
  end

  describe 'given --image image' do
    it { should have_run 'boxfuse/boxfuse run --image=image' }
  end

  describe 'given --env env' do
    it { should have_run 'boxfuse/boxfuse run --env=env' }
  end

  describe 'given --args args' do
    it { should have_run 'boxfuse/boxfuse run args' }
  end

  describe 'given --extra_args args' do
    it { should have_run 'boxfuse/boxfuse run args' }
    it { should have_deprecated :extra_args }
  end
end
