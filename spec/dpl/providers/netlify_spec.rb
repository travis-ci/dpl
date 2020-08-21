describe Dpl::Providers::Netlify do
  let(:args) { |e| %w(--auth token --site id) + args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_run '[npm:install] netlify-cli (netlify)' }
    it { should have_run 'netlify deploy --site="id" --auth="token"' }
  end

  describe 'given --dir ./dir' do
    it { should have_run 'netlify deploy --site="id" --auth="token" --dir="./dir"' }
  end

  describe 'given --functions ./functions' do
    it { should have_run 'netlify deploy --site="id" --auth="token" --functions="./functions"' }
  end

  describe 'given --message message' do
    it { should have_run 'netlify deploy --site="id" --auth="token" --message="message"' }
  end

  describe 'given --prod' do
    it { should have_run 'netlify deploy --site="id" --auth="token" --prod' }
  end

  describe 'given --json' do
    it { should have_run 'netlify deploy --site="id" --auth="token" --json' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--site id) }
    env NETLIFY_AUTH: 'token'
    it { expect { subject.run }.to_not raise_error }
  end
end
