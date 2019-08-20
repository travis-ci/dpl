describe Dpl::Zip do
  subject { described_class.new(path, 'test.zip') }

  file 'one'
  file 'two'

  describe 'given a file' do
    let(:path) { 'one' }
    before { subject.zip }
    it { should have_zipped 'test.zip', 'one' }
  end

  describe 'given a directory' do
    let(:path) { '.' }
    before { subject.zip }
    it { should have_zipped 'test.zip', 'one', 'two' }
  end

  describe 'given a zip file' do
    let(:path) { 'one.zip' }
    file 'one.zip'
    before { subject.zip }
    it { expect(File.exists?('test.zip')).to be true }
  end
end
