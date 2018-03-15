require 'spec_helper'
require 'dpl/provider/pypi'

describe DPL::Provider::PyPI do
  subject :provider do
    described_class.new(DummyContext.new, :user => 'foo', :password => 'bar')
  end

  describe "#install_deploy_dependencies" do
    example do
      expect(provider.context).to receive(:shell).with(
        "wget -O - https://bootstrap.pypa.io/get-pip.py | python - --no-setuptools --no-wheel && pip install --upgrade setuptools twine wheel"
      ).and_return(true)
      provider.install_deploy_dependencies
    end
  end

  describe "#config" do
    it 'accepts a user and a password' do
      expect(provider.config[:servers]['pypi']).to include 'username: foo'
      expect(provider.config[:servers]['pypi']).to include 'password: bar'
    end
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:log).with("Authenticated as foo")
      provider.check_auth
    end
  end

  describe "#push_app" do
    example "default" do
      expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
      expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
      expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
      expect(provider.context).not_to receive(:shell).with("python setup.py upload_docs  -r https://upload.pypi.org/legacy/")
      provider.push_app
    end

    example "with :distributions option" do
      provider.options.update(:distributions => 'sdist bdist')
      expect(provider.context).to receive(:shell).with("python setup.py sdist bdist").and_return(true)
      expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
      expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
      expect(provider.context).not_to receive(:shell).with("python setup.py upload_docs  -r https://upload.pypi.org/legacy/")
      provider.push_app
    end

    example "with :server option" do
      provider.options.update(:server => 'http://blah.com')
      expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
      expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
      expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
      expect(provider.context).not_to receive(:shell).with("python setup.py upload_docs  -r http://blah.com")
      provider.push_app
    end

    example "with :skip_existing option being false" do
      provider.options.update(:skip_existing => false)
      expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
      expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
      expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
      expect(provider.context).not_to receive(:shell).with("python setup.py upload_docs  -r https://upload.pypi.org/legacy/")
      provider.push_app
    end

    example "with :skip_existing option being true" do
      provider.options.update(:skip_existing => true)
      expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
      expect(provider.context).to receive(:shell).with("twine upload --skip-existing -r pypi dist/*").and_return(true)
      expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
      expect(provider.context).not_to receive(:shell).with("python setup.py upload_docs  -r https://upload.pypi.org/legacy/")
      provider.push_app
    end

    example "with :skip_upload_docs option" do
      provider.options.update(:skip_upload_docs => true)
      expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
      expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
      expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
      expect(provider.context).not_to receive(:shell).with("python setup.py upload_docs -r https://upload.pypi.org/legacy/")
      provider.push_app
    end

    context "with :skip_upload_docs option being false" do
      before :each do
        provider.options.update(:skip_upload_docs => false)
      end

      it "runs upload_docs" do
        expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
        expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
        expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
        expect(provider.context).to receive(:shell).with("python setup.py upload_docs  -r https://upload.pypi.org/legacy/").and_return(true)
        provider.push_app
      end

      example "with :docs_dir option" do
        provider.options.update(:docs_dir => 'some/dir')
        expect(provider.context).to receive(:shell).with("python setup.py sdist").and_return(true)
        expect(provider.context).to receive(:shell).with("twine upload -r pypi dist/*").and_return(true)
        expect(provider.context).to receive(:shell).with("rm -rf dist/*").and_return(true)
        expect(provider.context).to receive(:shell).with("python setup.py upload_docs --upload-dir some/dir -r https://upload.pypi.org/legacy/").and_return(true)
        provider.push_app
      end
    end

  end

  describe "#write_servers" do
    example do
      f = double(:f)
      expect(f).to receive(:puts).with("    pypi")
      expect(f).to receive(:puts).with("[pypi]")
      expect(f).to receive(:puts).with(["repository: https://upload.pypi.org/legacy/",
                                    "username: foo",
                                    "password: bar"
                                   ])
      provider.write_servers(f)
    end
  end
end
