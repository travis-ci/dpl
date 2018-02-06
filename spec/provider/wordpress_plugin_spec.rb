require 'spec_helper'

describe DPL::Provider::WordpressPlugin do
  let(:options) do
    {
      slug: 'my-plugin',
      username: 'my-name',
      password: 'my-password',
      build_dir: 'my/build/dir',
      assets_dir: 'my/assets/dir'
    }
  end

  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  before(:each) do
    FileUtils.mkdir_p options[:build_dir]
    FileUtils.mkdir_p options[:assets_dir]

    allow(provider).to receive(:tag).and_return('1.0.0')
  end

  after(:each) do
    FileUtils.rm_rf('my')
    FileUtils.rm_rf('/tmp/wordpress-plugin-deploy')
  end

  describe '#needs_key?' do
    it 'always return false' do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe '#check_auth' do
    example 'with proper options' do
      expect(provider).to receive(:log).with('Finding configuration for WordPress plugin deployment...')
      expect(provider).to receive(:log).with('Slug: my-plugin')
      expect(provider).to receive(:log).with('Username: my-name')
      expect(provider).to receive(:log).with('Password found')
      expect(provider).to receive(:log).with('Build Directory: my/build/dir')
      expect(provider).to receive(:log).with('Assets Directory: my/assets/dir')

      provider.check_auth
    end

    it 'calls its private methods' do
      allow(provider).to receive(:log)

      expect(provider).to receive(:slug)
      expect(provider).to receive(:username)
      expect(provider).to receive(:password)
      expect(provider).to receive(:build_dir)
      expect(provider).to receive(:assets_dir)

      provider.check_auth
    end
  end

  describe '#check_app' do
    example 'with proper options' do
      expect(provider).to receive(:log).with('Validating configuration for WordPress plugin deployment...').ordered
      expect(provider).to receive(:log).with('Configuration looks good').ordered
      expect(provider).to receive(:log).with('Going to deloy tag: 1.0.0').ordered

      provider.check_app
    end

    example 'when assets_dir is not set' do
      provider.options.delete(:assets_dir)

      expect(provider).to receive(:log).with('Validating configuration for WordPress plugin deployment...').ordered
      expect(provider).to receive(:log).with('Configuration looks good').ordered
      expect(provider).to receive(:log).with('Going to deloy tag: 1.0.0').ordered

      provider.check_app
    end

    example 'when build directory does not exist' do
      FileUtils.remove_dir 'my/build/dir'
      allow(provider).to receive(:log)

      expect { provider.check_app }.to raise_error(DPL::Error, 'Build directory does not exist')
    end

    example 'when assets directory is set but not exist' do
      FileUtils.rm_r 'my/assets/dir'
      allow(provider).to receive(:log)

      expect { provider.check_app }.to raise_error(DPL::Error, 'Assets directory is set but not exist')
    end

    example 'when unable to determine tag version' do
      allow(provider).to receive(:tag).and_return('')
      allow(provider).to receive(:log)

      expect { provider.check_app }.to raise_error(DPL::Error, 'Unable to determine tag version')
    end
  end

  describe '#push_app' do
    example 'when deploy both build and assets' do
      expect(provider).to receive(:svn_checkout).with('/tmp/wordpress-plugin-deploy').with('/tmp/wordpress-plugin-deploy').ordered
      expect(provider).to receive(:svn_tag_exist?).with('/tmp/wordpress-plugin-deploy').ordered

      expect(provider).to receive(:clear).with('/tmp/wordpress-plugin-deploy/trunk').ordered
      expect(provider).to receive(:clear).with('/tmp/wordpress-plugin-deploy/assets').ordered

      expect(provider).to receive(:svn_delete).with('/tmp/wordpress-plugin-deploy').ordered
      expect(provider).to receive(:svn_commit).with('Temporary removing trunk and assets(if assets_dir is set)', '/tmp/wordpress-plugin-deploy').ordered

      expect(provider).to receive(:copy).with('my/build/dir', '/tmp/wordpress-plugin-deploy/trunk').ordered
      expect(provider).to receive(:copy).with('/tmp/wordpress-plugin-deploy/trunk', '/tmp/wordpress-plugin-deploy/tags/1.0.0').ordered
      expect(provider).to receive(:copy).with('my/assets/dir', '/tmp/wordpress-plugin-deploy/assets').ordered

      expect(provider).to receive(:svn_add).with('/tmp/wordpress-plugin-deploy').ordered
      expect(provider).to receive(:svn_commit).with('Committing 1.0.0', '/tmp/wordpress-plugin-deploy').ordered

      provider.send(:push_svn, '/tmp/wordpress-plugin-deploy')
    end

    example 'when deploy build but not assets' do
      provider.options.delete(:assets_dir)

      expect(provider).to receive(:svn_checkout).with('/tmp/wordpress-plugin-deploy').with('/tmp/wordpress-plugin-deploy').ordered
      expect(provider).to receive(:svn_tag_exist?).with('/tmp/wordpress-plugin-deploy').ordered

      expect(provider).to receive(:clear).with('/tmp/wordpress-plugin-deploy/trunk').ordered

      expect(provider).to receive(:svn_delete).ordered
      expect(provider).to receive(:svn_commit).with('Temporary removing trunk and assets(if assets_dir is set)', '/tmp/wordpress-plugin-deploy').ordered

      expect(provider).to receive(:copy).with('my/build/dir', '/tmp/wordpress-plugin-deploy/trunk').ordered
      expect(provider).to receive(:copy).with('/tmp/wordpress-plugin-deploy/trunk', '/tmp/wordpress-plugin-deploy/tags/1.0.0').ordered
      expect(provider).not_to receive(:copy).with('my/assets/dir', '/tmp/wordpress-plugin-deploy/assets')

      expect(provider).to receive(:svn_add).with('/tmp/wordpress-plugin-deploy').ordered
      expect(provider).to receive(:svn_commit).with('Committing 1.0.0', '/tmp/wordpress-plugin-deploy').ordered

      expect(provider).not_to receive(:clear).with('/tmp/wordpress-plugin-deploy/assets')
      expect(provider).not_to receive(:copy).with(nil, '/tmp/wordpress-plugin-deploy/assets')

      provider.send(:push_svn, '/tmp/wordpress-plugin-deploy')
    end
  end

  describe '#svn_checkout' do
    it do
      expect(provider).to receive(:log).with('Checking out https://plugins.svn.wordpress.org/my-plugin')
      expect(provider.context).to receive(:shell).with('svn co --quiet --non-interactive https://plugins.svn.wordpress.org/my-plugin /tmp/wordpress-plugin-deploy')

      provider.send(:svn_checkout, '/tmp/wordpress-plugin-deploy')
    end
  end

  describe '#svn_tag_exist?' do
    example 'when tag already exists on subversion server' do
      expect(provider.send(:svn_tag_exist?, '/tmp/wordpress-plugin-deploy')).to eq(false)
    end

    example 'when tag already exists on subversion server' do
      FileUtils.mkdir_p '/tmp/wordpress-plugin-deploy/tags/1.0.0'

      expect(provider.send(:svn_tag_exist?, '/tmp/wordpress-plugin-deploy')).to eq(true)
    end
  end

  describe '#clear' do
    it do
      allow(FileUtils).to receive(:rm_rf)

      expect(provider).to receive(:log).with('Clearing /tmp/wordpress-plugin-deploy/trunk...').ordered
      expect(FileUtils).to receive(:rm_rf).with('/tmp/wordpress-plugin-deploy/trunk').ordered

      provider.send(:clear, '/tmp/wordpress-plugin-deploy/trunk')
    end
  end

  describe '#copy' do
    it do
      expect(provider).to receive(:log).with('Copying my/build/dir to /tmp/wordpress-plugin-deploy/trunk...')
      expect(FileUtils).to receive(:cp_r).with('my/build/dir/.', '/tmp/wordpress-plugin-deploy/trunk')

      provider.send(:copy, 'my/build/dir', '/tmp/wordpress-plugin-deploy/trunk')
    end
  end

  describe '#svn_add' do
    it do
      expect(provider).to receive(:log).with('Adding new files to subversion...')
      expect(provider.context).to receive(:shell).with("svn status /tmp/wordpress-plugin-deploy | grep '^?' | awk '{print $2}' | xargs -I x svn add x@")

      provider.send(:svn_add, "/tmp/wordpress-plugin-deploy")
    end
  end

  describe '#svn_delete' do
    it do
      expect(provider).to receive(:log).with('Removing deleted files from subversion...')
      expect(provider.context).to receive(:shell).with("svn status /tmp/wordpress-plugin-deploy | grep '^!' | awk '{print $2}' | xargs -I x svn delete --force x@")

      provider.send(:svn_delete, "/tmp/wordpress-plugin-deploy")
    end
  end

  describe '#svn_commit' do
    it do
      expect(provider).to receive(:log).with('some message')
      expect(provider.context).to receive(:shell).with("svn commit --no-auth-cache --non-interactive --username 'my-name' --password 'my-password' /tmp/wordpress-plugin-deploy -m 'some message'")

      provider.send(:svn_commit, 'some message', "/tmp/wordpress-plugin-deploy")
    end
  end

  ### private methods

  describe '#slug' do
    example 'when $WORDPRESS_PLUGIN_SLUG is set' do
      provider.context.env['WORDPRESS_PLUGIN_SLUG'] = 'my-env-plugin'

      expect(provider.send(:slug)).to eq('my-env-plugin')
    end

    example 'when slug is set' do
      expect(provider.send(:slug)).to eq('my-plugin')
    end

    example 'when both $WORDPRESS_PLUGIN_SLUG and slug are not set' do
      provider.options.delete(:slug)

      expect { provider.send(:slug) }.to raise_error(DPL::Error, 'missing slug')
    end
  end

  describe '#username' do
    example 'when $WORDPRESS_PLUGIN_USERNAME is set' do
      provider.context.env['WORDPRESS_PLUGIN_USERNAME'] = 'my-env-name'

      expect(provider.send(:username)).to eq('my-env-name')
    end

    example 'when username is set' do
      expect(provider.send(:username)).to eq('my-name')
    end

    example 'when both $WORDPRESS_PLUGIN_USERNAME and username are not set' do
      provider.options.delete(:username)

      expect { provider.send(:username) }.to raise_error(DPL::Error, 'missing username')
    end
  end

  describe '#password' do
    example 'when $WORDPRESS_PLUGIN_PASSWORD is set' do
      provider.context.env['WORDPRESS_PLUGIN_PASSWORD'] = 'my-env-password'

      expect(provider.send(:password)).to eq('my-env-password')
    end

    example 'when password is set' do
      expect(provider.send(:password)).to eq('my-password')
    end

    example 'when both $WORDPRESS_PLUGIN_PASSWORD and password are not set' do
      provider.options.delete(:password)

      expect { provider.send(:password) }.to raise_error(DPL::Error, 'missing password')
    end
  end

  describe '#build_dir' do
    example 'when $WORDPRESS_PLUGIN_BUILD_DIR is set' do
      provider.context.env['WORDPRESS_PLUGIN_BUILD_DIR'] = 'my/env/build/dir'

      expect(provider.send(:build_dir)).to eq('my/env/build/dir')
    end

    example 'when build_dir is set' do
      expect(provider.send(:build_dir)).to eq('my/build/dir')
    end

    example 'when both $WORDPRESS_PLUGIN_BUILD_DIR and build_dir are not set' do
      provider.options.delete(:build_dir)

      expect { provider.send(:build_dir) }.to raise_error(DPL::Error, 'missing build_dir')
    end
  end

  describe '#assets_dir' do
    example 'when $WORDPRESS_PLUGIN_ASSETS_DIR is set' do
      provider.context.env['WORDPRESS_PLUGIN_ASSETS_DIR'] = 'my/env/assets/dir'

      expect(provider.send(:assets_dir)).to eq('my/env/assets/dir')
    end

    example 'when assets_dir is set' do
      expect(provider.send(:assets_dir)).to eq('my/assets/dir')
    end

    example 'when both $WORDPRESS_PLUGIN_ASSETS_DIR and assets_dir are not set' do
      provider.options.delete(:assets_dir)

      expect(provider.send(:assets_dir)).to eq(nil)
    end
  end

  describe '#svn_url' do
    it 'replaces {{slug}} with real slug' do
      expect(provider.send(:svn_url)).to eq('https://plugins.svn.wordpress.org/my-plugin')
    end
  end

  describe '#tag' do
    before(:each) { allow(provider).to receive(:tag).and_call_original }

    example 'without $TRAVIS_TAG' do
      allow(provider).to receive(:travis_tag).and_return('')
      allow(provider).to receive(:`).and_return('bar')

      expect(provider.send(:tag)).to eq('bar')
    end

    example 'with $TRAVIS_TAG' do
      allow(provider).to receive(:travis_tag).and_return('foo')

      expect(provider.send(:tag)).to eq('foo')
    end
  end

  describe '#travis_tag' do
    example 'when $TRAVIS_TAG not set' do
      provider.context.env['TRAVIS_TAG'] = nil

      expect(provider.send(:travis_tag)).to eq('')
    end

    example 'when $TRAVIS_TAG is set' do
      provider.context.env['TRAVIS_TAG'] = 'foo'

      expect(provider.send(:travis_tag)).to eq('foo')
    end
  end
end
