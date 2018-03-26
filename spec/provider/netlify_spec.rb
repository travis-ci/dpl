require 'spec_helper'
require 'dpl/provider/netlify'

describe DPL::Provider::Netlify do
  subject :provider do
    described_class.new(DummyContext.new, :directory => './')
  end
 
  describe '#check_auth' do
    it 'should raise an error if NETLIFY_TOKEN nor NETLIFY_SITE_ID isnt set' do
      expect{ provider.check_auth }.to raise_error('> Error!! Please add NETLIFY_TOKEN & NETLIFY_SITE_ID Environment Variables in Travis settings (get it here https://app.netlify.com/applications)')
    end

    it 'should not raise error if NOW_TOKEN is set' do
      provider.context.env['NETLIFY_TOKEN'] = '000000000000000000000000'
      provider.context.env['NETLIFY_SITE_ID'] = '00000-00000-000000-00000000'
      expect{ provider.check_auth }.not_to raise_error
    end
  end

  describe '#auth' do
    it 'should return auth' do
      provider.context.env['NETLIFY_TOKEN'] = '000000000000000000000000'
      expect(provider.auth).to eq('-A 000000000000000000000000')
    end
  end

  describe '#check_app' do
    it 'should raise an error if directory not exist' do
      provider.options.update(directory: './not-exist')
      expect{ provider.check_app }.to raise_error('> Error!! Please set a valid project folder path in .travis.yml under deploy: directory: myPath')
    end

    it 'should not raise error if directory exist' do
      provider.options.update(directory: './')
      expect{ provider.check_app }.not_to raise_error
    end
  end

  describe '#deploy_options' do
    it 'should return basic deploy options' do
      expect(provider.deploy_options).to eq('-b ' + File.expand_path('./'))
    end
  end

  describe '#needs_key?' do
    it { expect(provider.needs_key?).to eq(false) }
  end

  describe '#push_app' do
    before do
      provider.context.env['NETLIFY_TOKEN'] = '000000000000000000000000'
      provider.context.env['NETLIFY_SITE_ID'] = '00000-00000-000000-00000000'
    end
    it 'should deploy' do
      allow(provider.context).to receive(:shell).and_return(true)
      expect(provider.context).to receive(:shell).with('netlifyctl deploy -y -A 000000000000000000000000 -s 00000-00000-000000-00000000 -b ' + File.expand_path('./'))
      provider.push_app
    end
  end
end