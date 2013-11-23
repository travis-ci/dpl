require 'spec_helper'
require 'dpl/provider/pypi'

describe DPL::Provider::PyPI do
  subject :provider do
    described_class.new(DummyContext.new, :user => 'foo', :password => 'bar')
  end

  describe :config do
    it 'accepts a user and a password' do
      provider.config[:servers]['pypi'].should include 'username: foo'
      provider.config[:servers]['pypi'].should include 'password: bar'
    end
  end

  describe :initialize do
    example "with :distributions option containing 'bdist_wheel'" do
      described_class.should_receive(:pip).with("wheel")
      described_class.new(DummyContext.new, :user => 'foo', :password => 'bar', :distributions => 'bdist_wheel sdist')
    end
  end

  describe :check_auth do
    example do
      provider.should_receive(:log).with("Authenticated as foo")
      provider.check_auth
    end
  end

  describe :push_app do
    example do
      provider.context.should_receive(:shell).with("python setup.py register -r pypi")
      provider.context.should_receive(:shell).with("python setup.py sdist upload -r pypi")
      provider.context.should_receive(:shell).with("python setup.py upload_docs --upload-dir build/docs")
      provider.push_app
    end

    example "with :distributions option" do
      provider.options.update(:distributions => 'sdist bdist')
      provider.context.should_receive(:shell).with("python setup.py register -r pypi")
      provider.context.should_receive(:shell).with("python setup.py sdist bdist upload -r pypi")
      provider.context.should_receive(:shell).with("python setup.py upload_docs --upload-dir build/docs")
      provider.push_app
    end

    example "with :server option" do
      provider.options.update(:server => 'http://blah.com')
      provider.context.should_receive(:shell).with("python setup.py register -r http://blah.com")
      provider.context.should_receive(:shell).with("python setup.py sdist upload -r http://blah.com")
      provider.context.should_receive(:shell).with("python setup.py upload_docs --upload-dir build/docs")
      provider.push_app
    end

    example "with :docs_dir option" do
      provider.options.update(:docs_dir => 'some/dir')
      provider.context.should_receive(:shell).with("python setup.py register -r pypi")
      provider.context.should_receive(:shell).with("python setup.py sdist upload -r pypi")
      provider.context.should_receive(:shell).with("python setup.py upload_docs --upload-dir some/dir")
      provider.push_app
    end
  end

  describe :write_servers do
    example do
      f = double(:f)
      f.should_receive(:puts).with("    pypi")
      f.should_receive(:puts).with("[pypi]")
      f.should_receive(:puts).with(["repository: http://www.python.org/pypi",
                                    "username: foo",
                                    "password: bar"
                                   ])
      provider.write_servers(f)
    end
  end
end
