describe Dpl::Interpolate do
  let(:provider) { Class.new(Dpl::Provider, &body).new(ctx, %w(--password secret)) }
  let(:body) { ->(*) { opt '--password PASS', secret: true } }
  let(:args) { [] }
  let(:opts) { {} }

  subject { provider.interpolate(str, args, opts) }

  describe 'obj accessor' do
    let(:str)  { 'string containing %{password}' }
    it { should eq 'string containing s*******************' }
  end

  describe 'passing args as an array' do
    let(:str)  { 'string containing %s' }
    let(:args) { ['secret'.taint] }
    it { should eq 'string containing s*******************' }
  end

  describe 'given secure: true' do
    let(:str)  { 'string containing %{password}' }
    let(:opts) { { secure: true } }
    it { should eq 'string containing secret' }
  end

  describe 'interpolating an env var' do
    let(:str) { 'string containing %{$VAR}' }
    env VAR: :var
    it { should eq 'string containing var' }
  end

  describe 'interpolating a const' do
    let(:str) { 'string containing %{CONST}' }
    before { provider.class.const_set(:CONST, 'const') }
    it { should eq 'string containing const' }
  end

  describe 'interpolating an undefined const' do
    let(:str) { 'string containing %{CONST}' }
    it { expect { subject }.to raise_error KeyError, 'CONST' }
  end
end
