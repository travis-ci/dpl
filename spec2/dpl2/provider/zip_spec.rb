describe Dpl::Zip do
  let(:zip)  { described_class.new(src, dest, opts) }
  let(:src)  { '.' }
  let(:dest) { 'file.zip' }
  let(:opts) { {} }

  chdir 'tmp'
  file '.dot'
  file 'one'
  file 'two/one'
  file 'two/two'

  subject { Dir.glob('**/*', File::FNM_DOTMATCH).sort }

  before do
    zip.zip
    rm_r '.dot', 'one', 'two'
    system 'unzip file.zip > /dev/null 2>&1'
    rm 'file.zip'
  end

  describe 'without dot_match' do
    it { should eq %w(. one two two/. two/one two/two) }
  end

  describe 'with dot_match' do
    let(:opts) { { dot_match: true } }
    it { should eq %w(. .dot one two two/. two/one two/two) }
  end

  describe 'src being a subdir' do
    let(:src) { 'two' }
    it { should eq %w(. one two) }
  end
end
