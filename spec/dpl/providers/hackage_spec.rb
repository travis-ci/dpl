# frozen_string_literal: true

describe Dpl::Providers::Hackage do
  let(:args) { |e| %w[--username user --password pass] + args_from_description(e) }

  file 'dist/one.tar.gz'
  file 'dist/two.tar.gz'

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { is_expected.to have_run 'cabal check' }
    it { is_expected.to have_run 'cabal sdist' }
    it { is_expected.to have_run 'cabal upload --username="user" --password="pass" dist/one.tar.gz' }
    it { is_expected.to have_run 'cabal upload --username="user" --password="pass" dist/two.tar.gz' }
    it { is_expected.to have_run_in_order }
  end

  describe 'given --publish' do
    it { is_expected.to have_run 'cabal upload --publish --username="user" --password="pass" dist/one.tar.gz' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }

    env HACKAGE_USERNAME: 'user',
        HACKAGE_PASSWORD: 'pass'
    it { expect { subject.run }.not_to raise_error }
  end
end
