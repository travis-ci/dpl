describe Dpl::Interpolate do
  subject(:interpolate) { provider.interpolate(str, args, opts) }

  let(:provider) { Class.new(Dpl::Provider, &body).new(ctx, %w[--name a-name --password secret]) }
  let(:body) do
    lambda do |*|
      opt '--name NAME'
      opt '--password PASS', secret: true
    end
  end
  let(:args) { [] }
  let(:opts) { {} }

  describe 'obj accessor' do
    let(:str) { 'string containing %{password}' }

    it { is_expected.to eq 'string containing s*******************' }
  end

  describe 'passing args as an array' do
    let(:str)  { 'string containing %s' }
    let(:args) { ['secret'.blacklist] }

    it { is_expected.to eq 'string containing s*******************' }
  end

  describe 'given secure: true' do
    let(:str)  { 'string containing %{password}' }
    let(:opts) { { secure: true } }

    it { is_expected.to eq 'string containing secret' }
  end

  describe 'interpolating an env var' do
    let(:str) { 'string containing %{$VAR}' }

    env VAR: :var
    it { is_expected.to eq 'string containing var' }
  end

  describe 'interpolating a const' do
    let(:str) { 'string containing %{CONST}' }

    before { provider.class.const_set(:CONST, 'const') }

    it { is_expected.to eq 'string containing const' }
  end

  describe 'interpolating an undefined const' do
    let(:str) { 'string containing %{CONST}' }

    it { expect { interpolate }.to raise_error KeyError, 'CONST' }
  end

  describe 'safelisting vars' do
    let(:opts) { { vars: [:name] } }

    describe 'known var' do
      let(:str) { 'string containing %{name}' }

      it { is_expected.to eq 'string containing a-name' }
    end

    describe 'unknown var' do
      let(:str) { 'string containing %{unknown}' }

      it { is_expected.to eq 'string containing [unknown variable: unknown]' }
    end
  end
end
