# frozen_string_literal: true

describe Dpl::Cli do
  subject { |e| cli.normalize(e.example_group.description.split(' ')) }

  let(:cli) { described_class.new(ctx) }

  describe 'heroku --strategy=api --api_key=key' do
    it { is_expected.to eq %w[heroku api --api_key=key] }
  end

  describe 'heroku --strategy api --api_key key' do
    it { is_expected.to eq %w[heroku api --api_key key] }
  end

  describe '--provider=heroku --strategy=api --api_key=key' do
    it { is_expected.to eq %w[heroku api --api_key=key] }
  end

  describe '--provider heroku --strategy api --api_key key' do
    it { is_expected.to eq %w[heroku api --api_key key] }
  end

  describe '--api_key=key --provider=heroku --strategy=api' do
    it { is_expected.to eq %w[heroku api --api_key=key] }
  end

  describe '--api_key key --provider heroku --strategy api' do
    it { is_expected.to eq %w[heroku api --api_key key] }
  end
end
