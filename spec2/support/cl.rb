module Support
  module Cl
    def self.included(base)
      base.let(:args) { |e| args_from_description(e) }
      base.subject { cmd }
    end

    def args_from_description(e)
      str = e.example_group.description
      str.include?('given') ? str.sub('given', '').strip.split(' ') : []
    end

    def runner(args = nil)
      args ||= respond_to?(:args) ? self.args : args_from_description
      args = [described_class.registry_key.to_s, *args]
      ::Cl.new(ctx, 'dpl').runner(args)
    end

    def cmd(args = nil)
      runner(args).cmd
    end

    def run
      runner.run
    end
  end
end
