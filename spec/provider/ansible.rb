require 'spec_helper'
require 'dpl/provider/ansible'

describe DPL::Provider::Ansible do
  subject :provider do
    described_class.new(DummyContext.new, {} )
  end

  describe "#push_app" do
    example "Default All" do
      expect(provider.context).to receive(:shell).with('ansible-playbook .playbook.yml')
      provider.push_app
    end

    example "Set playbook" do
      provider.options.update(:playbook => "myplaybook.yml")
      expect(provider.context).to receive(:shell).with('ansible-playbook myplaybook.yml')
      provider.push_app
    end

    example "Set verbose" do
      provider.options.update(:verbose => true)
      expect(provider.context).to receive(:shell).with('ansible-playbook .playbook.yml --verbose')
      provider.push_app
    end

    example "Handle extra-args" do
      provider.options.update('extra-args' => "-some -extra -args")
      expect(provider.context).to receive(:shell).with('ansible-playbook .playbook.yml -some -extra -args')
      provider.push_app
    end
  end

end
