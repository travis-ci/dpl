describe Dpl::Env::Env do
  let(:const) { Class.new(Dpl::Provider) { opt '--two str' } }
  let(:opts)  { {} }

  subject { described_class.new(stringify(env), [*strs, opts]).env(const) }

  describe 'env var matching prefix and option' do
    let(:strs) { [:one] }
    let(:env)  { { ONE_TWO: 'two' } }
    it { should eq two: 'two' }
  end

  describe 'env var matching prefix but not option' do
    let(:strs) { [:one] }
    let(:env)  { { ONE_THREE: 'three' } }
    it { should be_empty }
  end

  describe 'env var matching option but not prefix' do
    let(:strs) { [:two] }
    let(:env)  { { ONE_TWO: 'two' } }
    it { should be_empty }
  end
end
