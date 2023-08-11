# frozen_string_literal: true

describe Dpl::Providers::Netlify do
  let(:args) { |e| %w(--auth token --site id) + args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { is_expected.to have_run '[npm:install] netlify-cli (netlify)' }
    it { is_expected.to have_run 'netlify deploy --site="id" --auth="token"' }
  end

  describe 'given --dir ./dir' do
    it { is_expected.to have_run 'netlify deploy --site="id" --auth="token" --dir="./dir"' }
  end

  describe 'given --functions ./functions' do
    it { is_expected.to have_run 'netlify deploy --site="id" --auth="token" --functions="./functions"' }
  end

  describe 'given --message message' do
    it { is_expected.to have_run 'netlify deploy --site="id" --auth="token" --message="message"' }
  end

  describe 'given --prod' do
    it { is_expected.to have_run 'netlify deploy --site="id" --auth="token" --prod' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--site id) }

    env NETLIFY_AUTH: 'token'
    it { expect { subject.run }.not_to raise_error }
  end
end
