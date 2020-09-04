describe Dpl::Zip do
  subject { described_class.new(path, 'test.zip') }

  file 'one'
  file 'two'

  describe 'given a file' do
    let(:path) { 'one' }
    before { subject.zip }
    it { should have_zipped 'test.zip', %w(one) }
  end

  describe 'given a directory' do
    let(:path) { '.' }
    before { subject.zip }
    it { should have_zipped 'test.zip', %w(one two) }
  end

  describe 'given a zip file' do
    let(:path) { 'one.zip' }
    file 'one.zip'
    it { expect(subject.zip.path).to eq 'one.zip' }
  end
end
