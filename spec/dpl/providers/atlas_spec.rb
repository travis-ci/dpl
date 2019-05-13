describe Dpl::Providers::Atlas do
  let(:args) { |e| %w(--app app --token token) + args_from_description(e) }

  before { subject.run }

  describe 'by default' do
    it { should have_env ATLAS_TOKEN: 'token' }
    it { should have_run '[script] install' }
    it { should have_run 'atlas-upload app .' }
    it { should have_run_in_order }
  end

  describe 'given --path ./one --path ./two' do
    it { should have_run 'atlas-upload app ./one' }
    it { should have_run 'atlas-upload app ./two' }
  end

  describe 'given --address http://address' do
    it { should have_run 'atlas-upload -address="http://address" app .' }
  end

  describe 'given --include one/*.ext --include two/*.ext' do
    it { should have_run 'atlas-upload -include="one/*.ext" -include="two/*.ext" app .' }
  end

  describe 'given --exclude one/*.ext --exclude two/*.ext' do
    it { should have_run 'atlas-upload -exclude="one/*.ext" -exclude="two/*.ext" app .' }
  end

  describe 'given --metadata one=one --metadata two=two' do
    it { should have_run 'atlas-upload -metadata="one=one" -metadata="two=two" app .' }
  end

  describe 'given --vcs' do
    it { should have_run 'atlas-upload -vcs app .' }
  end

  describe 'given --debug' do
    it { should have_run 'atlas-upload -debug app .' }
  end
end
