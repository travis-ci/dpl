# frozen_string_literal: true

describe Dpl::Zip do
  subject(:zip) { described_class.new(path, 'test.zip') }

  file 'one'
  file 'two'

  describe 'given a file' do
    let(:path) { 'one' }

    before { zip.zip }

    it { is_expected.to have_zipped 'test.zip', %w[one] }
  end

  describe 'given a directory' do
    let(:path) { '.' }

    before { zip.zip }

    it { is_expected.to have_zipped 'test.zip', %w[one two] }
  end

  describe 'given a zip file' do
    let(:path) { 'one.zip' }

    file 'one.zip'
    it { expect(zip.zip.path).to eq 'one.zip' }
  end
end
