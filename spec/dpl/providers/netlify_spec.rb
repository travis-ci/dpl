describe Dpl::Providers::Netlify do
  let(:args) { |e| %w(--auth token --site id) + args_from_description(e) }

  before { subject.run }

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
end
