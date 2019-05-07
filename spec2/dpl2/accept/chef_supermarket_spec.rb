describe Dpl::Providers::ChefSupermarket, 'acceptance' do
  let(:args) { |e| %w(--user_id id --client_key key --cookbook_category cat) + args_from_description(e) }

  before { subject.run }
      # opt 'user_id',           'Chef Supermarket user name', required: true
      # opt 'client_key',        'Client API key file name', required: true
      # opt 'cookbook_name',     'Cookbook name. Defaults to the current working dir basename'
      # opt 'cookbook_category', 'Cookbook category in Supermarket. See: https://docs.getchef.com/knife_cookbook_site.html#id12', required: true

  describe 'by default' do
    it { should have_run 'cmd' }
  end
end
