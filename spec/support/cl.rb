module Support
  module Cl
    module Sq
      # Beloved squiggly heredocs did not exist in Ruby 2.1.0, which we still
      # want to support, so let's give kudos with this method in the meantime.
      def sq(str)
        width = str =~ /( *)\S/ && $1.size
        str.lines.map { |line| line.gsub(/^ {#{width}}/, '') }.join
      end
    end

    def self.included(base)
      base.let(:provider) do
        next described_class if described_class.is_a?(Symbol)
        next described_class.registry_key if described_class.registry_key
        described_class.name.split('::').last.downcase
      end
      base.let(:args) { |e| args_from_description(e) }
      base.subject { cmd }
      base.extend Sq
    end

    include Sq

    def args_from_description(e)
      strs = e.example_group.parent_groups.map(&:description)
      args = strs.map do |str|
        next unless str.include?('given -')
        str = str.sub(/.*given /, '').sub(/\(.*/, '').strip
        strs = str.split(/\s(?=(?:[^"]|"[^"]*")*$)/)
        strs.map { |str| str.gsub('"', '') }
      end
      args.flatten.compact
    end

    def runner(args = nil)
      args ||= respond_to?(:args) ? self.args : args_from_description
      args = [provider.to_s, *args]
      Dpl::Cli.new(ctx, 'dpl').runner(args)
    end

    def cmd(args = nil)
      runner(args).cmd
    end

    def run
      runner.run
    end

    def run?(c)
      not c.metadata[:example_group][:run].is_a?(FalseClass)
    end
  end
end
