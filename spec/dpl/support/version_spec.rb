# frozen_string_literal: true

require 'dpl/support/version'

describe Version do
  subject { described_class.new(version) }

  matcher :satisfy do |requirement|
    match do |version|
      version.satisfies?(requirement)
    end
  end

  describe '~>' do
    describe '2' do
      let(:version) { '2' }

      it { is_expected.not_to satisfy '~> 1' }
      it { is_expected.not_to satisfy '~> 1.1' }
      it { is_expected.not_to satisfy '~> 1.1.1' }
      it { is_expected.to     satisfy '~> 2' }
      it { is_expected.to     satisfy '~> 2.3' }
      it { is_expected.to     satisfy '~> 2.3.3' }
      it { is_expected.to     satisfy '~> 2.3.4' }
      it { is_expected.to     satisfy '~> 2.3.5' }
      it { is_expected.to     satisfy '~> 2.4' }
      it { is_expected.not_to satisfy '~> 3' }
      it { is_expected.not_to satisfy '~> 3.1' }
      it { is_expected.not_to satisfy '~> 3.1.1' }
    end

    describe '2.3' do
      let(:version) { '2.3' }

      it { is_expected.not_to satisfy '~> 1' }
      it { is_expected.not_to satisfy '~> 1.1' }
      it { is_expected.not_to satisfy '~> 1.1.1' }
      it { is_expected.to     satisfy '~> 2' }
      it { is_expected.to     satisfy '~> 2.3' }
      it { is_expected.to     satisfy '~> 2.3.3' }
      it { is_expected.to     satisfy '~> 2.3.4' }
      it { is_expected.to     satisfy '~> 2.3.5' }
      it { is_expected.not_to satisfy '~> 2.4' }
      it { is_expected.not_to satisfy '~> 3' }
      it { is_expected.not_to satisfy '~> 3.1' }
      it { is_expected.not_to satisfy '~> 3.1.1' }
    end

    describe '2.3.4' do
      let(:version) { '2.3.4' }

      it { is_expected.not_to satisfy '~> 1' }
      it { is_expected.not_to satisfy '~> 1.1' }
      it { is_expected.not_to satisfy '~> 1.1.1' }
      it { is_expected.to     satisfy '~> 2' }
      it { is_expected.to     satisfy '~> 2.3' }
      it { is_expected.to     satisfy '~> 2.3.3' }
      it { is_expected.to     satisfy '~> 2.3.4' }
      it { is_expected.not_to satisfy '~> 2.3.5' }
      it { is_expected.not_to satisfy '~> 2.3.10' }
      it { is_expected.not_to satisfy '~> 2.4' }
      it { is_expected.not_to satisfy '~> 3' }
      it { is_expected.not_to satisfy '~> 3.1' }
      it { is_expected.not_to satisfy '~> 3.1.1' }
    end
  end

  describe '>' do
    describe '2' do
      let(:version) { '2' }

      it { is_expected.to     satisfy '> 1' }
      it { is_expected.to     satisfy '> 1.1' }
      it { is_expected.to     satisfy '> 1.1.1' }
      it { is_expected.not_to satisfy '> 2' }
      it { is_expected.not_to satisfy '> 2.3' }
      it { is_expected.not_to satisfy '> 2.3.3' }
      it { is_expected.not_to satisfy '> 2.3.4' }
      it { is_expected.not_to satisfy '> 2.3.5' }
      it { is_expected.not_to satisfy '> 2.4' }
      it { is_expected.not_to satisfy '> 3' }
      it { is_expected.not_to satisfy '> 3.1' }
      it { is_expected.not_to satisfy '> 3.1.1' }
    end

    describe '2.3' do
      let(:version) { '2.3' }

      it { is_expected.to     satisfy '> 1' }
      it { is_expected.to     satisfy '> 1.1' }
      it { is_expected.to     satisfy '> 1.1.1' }
      it { is_expected.to     satisfy '> 2' }
      it { is_expected.not_to satisfy '> 2.3' }
      it { is_expected.not_to satisfy '> 2.3.3' }
      it { is_expected.not_to satisfy '> 2.3.4' }
      it { is_expected.not_to satisfy '> 2.3.5' }
      it { is_expected.not_to satisfy '> 2.4' }
      it { is_expected.not_to satisfy '> 3' }
      it { is_expected.not_to satisfy '> 3.1' }
      it { is_expected.not_to satisfy '> 3.1.1' }
    end

    describe '2.3.4' do
      let(:version) { '2.3.4' }

      it { is_expected.to     satisfy '> 1' }
      it { is_expected.to     satisfy '> 1.1' }
      it { is_expected.to     satisfy '> 1.1.1' }
      it { is_expected.to     satisfy '> 2' }
      it { is_expected.to     satisfy '> 2.3' }
      it { is_expected.to     satisfy '> 2.3.3' }
      it { is_expected.not_to satisfy '> 2.3.4' }
      it { is_expected.not_to satisfy '> 2.3.5' }
      it { is_expected.not_to satisfy '> 2.4' }
      it { is_expected.not_to satisfy '> 3' }
      it { is_expected.not_to satisfy '> 3.1' }
      it { is_expected.not_to satisfy '> 3.1.1' }
    end
  end

  describe '>=' do
    describe '2' do
      let(:version) { '2' }

      it { is_expected.to     satisfy '>= 1' }
      it { is_expected.to     satisfy '>= 1.1' }
      it { is_expected.to     satisfy '>= 1.1.1' }
      it { is_expected.to     satisfy '>= 2' }
      it { is_expected.not_to satisfy '>= 2.3' }
      it { is_expected.not_to satisfy '>= 2.3.3' }
      it { is_expected.not_to satisfy '>= 2.3.4' }
      it { is_expected.not_to satisfy '>= 2.3.5' }
      it { is_expected.not_to satisfy '>= 2.4' }
      it { is_expected.not_to satisfy '>= 3' }
      it { is_expected.not_to satisfy '>= 3.1' }
      it { is_expected.not_to satisfy '>= 3.1.1' }
    end

    describe '2.3' do
      let(:version) { '2.3' }

      it { is_expected.to     satisfy '>= 1' }
      it { is_expected.to     satisfy '>= 1.1' }
      it { is_expected.to     satisfy '>= 1.1.1' }
      it { is_expected.to     satisfy '>= 2' }
      it { is_expected.to     satisfy '>= 2.3' }
      it { is_expected.not_to satisfy '>= 2.3.3' }
      it { is_expected.not_to satisfy '>= 2.3.4' }
      it { is_expected.not_to satisfy '>= 2.3.5' }
      it { is_expected.not_to satisfy '>= 2.4' }
      it { is_expected.not_to satisfy '>= 3' }
      it { is_expected.not_to satisfy '>= 3.1' }
      it { is_expected.not_to satisfy '>= 3.1.1' }
    end

    describe '2.3.4' do
      let(:version) { '2.3.4' }

      it { is_expected.to     satisfy '>= 1' }
      it { is_expected.to     satisfy '>= 1.1' }
      it { is_expected.to     satisfy '>= 1.1.1' }
      it { is_expected.to     satisfy '>= 2' }
      it { is_expected.to     satisfy '>= 2.3' }
      it { is_expected.to     satisfy '>= 2.3.3' }
      it { is_expected.to     satisfy '>= 2.3.4' }
      it { is_expected.not_to satisfy '>= 2.3.5' }
      it { is_expected.not_to satisfy '>= 2.4' }
      it { is_expected.not_to satisfy '>= 3' }
      it { is_expected.not_to satisfy '>= 3.1' }
      it { is_expected.not_to satisfy '>= 3.1.1' }
    end
  end

  describe '<=' do
    describe '2' do
      let(:version) { '2' }

      it { is_expected.not_to satisfy '<= 1' }
      it { is_expected.not_to satisfy '<= 1.1' }
      it { is_expected.not_to satisfy '<= 1.1.1' }
      it { is_expected.to     satisfy '<= 2' }
      it { is_expected.to     satisfy '<= 2.3' }
      it { is_expected.to     satisfy '<= 2.3.3' }
      it { is_expected.to     satisfy '<= 2.3.4' }
      it { is_expected.to     satisfy '<= 2.3.5' }
      it { is_expected.to     satisfy '<= 2.4' }
      it { is_expected.to     satisfy '<= 3' }
      it { is_expected.to     satisfy '<= 3.1' }
      it { is_expected.to     satisfy '<= 3.1.1' }
    end

    describe '2.3' do
      let(:version) { '2.3' }

      it { is_expected.not_to satisfy '<= 1' }
      it { is_expected.not_to satisfy '<= 1.1' }
      it { is_expected.not_to satisfy '<= 1.1.1' }
      it { is_expected.not_to satisfy '<= 2' }
      it { is_expected.to     satisfy '<= 2.3' }
      it { is_expected.to     satisfy '<= 2.3.3' }
      it { is_expected.to     satisfy '<= 2.3.4' }
      it { is_expected.to     satisfy '<= 2.3.5' }
      it { is_expected.to     satisfy '<= 2.4' }
      it { is_expected.to     satisfy '<= 3' }
      it { is_expected.to     satisfy '<= 3.1' }
      it { is_expected.to     satisfy '<= 3.1.1' }
    end

    describe '2.3.4' do
      let(:version) { '2.3.4' }

      it { is_expected.not_to satisfy '<= 1' }
      it { is_expected.not_to satisfy '<= 1.1' }
      it { is_expected.not_to satisfy '<= 1.1.1' }
      it { is_expected.not_to satisfy '<= 2' }
      it { is_expected.not_to satisfy '<= 2.3' }
      it { is_expected.not_to satisfy '<= 2.3.3' }
      it { is_expected.to     satisfy '<= 2.3.4' }
      it { is_expected.to     satisfy '<= 2.3.5' }
      it { is_expected.to     satisfy '<= 2.4' }
      it { is_expected.to     satisfy '<= 3' }
      it { is_expected.to     satisfy '<= 3.1' }
      it { is_expected.to     satisfy '<= 3.1.1' }
    end
  end

  describe '<' do
    describe '2' do
      let(:version) { '2' }

      it { is_expected.not_to satisfy '< 1' }
      it { is_expected.not_to satisfy '< 1.1' }
      it { is_expected.not_to satisfy '< 1.1.1' }
      it { is_expected.not_to satisfy '< 2' }
      it { is_expected.to     satisfy '< 2.3' }
      it { is_expected.to     satisfy '< 2.3.3' }
      it { is_expected.to     satisfy '< 2.3.4' }
      it { is_expected.to     satisfy '< 2.3.5' }
      it { is_expected.to     satisfy '< 2.4' }
      it { is_expected.to     satisfy '< 3' }
      it { is_expected.to     satisfy '< 3.1' }
      it { is_expected.to     satisfy '< 3.1.1' }
    end

    describe '2.3' do
      let(:version) { '2.3' }

      it { is_expected.not_to satisfy '< 1' }
      it { is_expected.not_to satisfy '< 1.1' }
      it { is_expected.not_to satisfy '< 1.1.1' }
      it { is_expected.not_to satisfy '< 2' }
      it { is_expected.not_to satisfy '< 2.3' }
      it { is_expected.to     satisfy '< 2.3.3' }
      it { is_expected.to     satisfy '< 2.3.4' }
      it { is_expected.to     satisfy '< 2.3.5' }
      it { is_expected.to     satisfy '< 2.4' }
      it { is_expected.to     satisfy '< 3' }
      it { is_expected.to     satisfy '< 3.1' }
      it { is_expected.to     satisfy '< 3.1.1' }
    end

    describe '2.3.4' do
      let(:version) { '2.3.4' }

      it { is_expected.not_to satisfy '< 1' }
      it { is_expected.not_to satisfy '< 1.1' }
      it { is_expected.not_to satisfy '< 1.1.1' }
      it { is_expected.not_to satisfy '< 2' }
      it { is_expected.not_to satisfy '< 2.3' }
      it { is_expected.not_to satisfy '< 2.3.3' }
      it { is_expected.not_to satisfy '< 2.3.4' }
      it { is_expected.to     satisfy '< 2.3.5' }
      it { is_expected.to     satisfy '< 2.4' }
      it { is_expected.to     satisfy '< 3' }
      it { is_expected.to     satisfy '< 3.1' }
      it { is_expected.to     satisfy '< 3.1.1' }
    end
  end

  describe '=' do
    describe '2' do
      let(:version) { '2' }

      it { is_expected.not_to satisfy '= 1' }
      it { is_expected.not_to satisfy '= 1.1' }
      it { is_expected.not_to satisfy '= 1.1.1' }
      it { is_expected.to     satisfy '= 2' }
      it { is_expected.not_to satisfy '= 2.3' }
      it { is_expected.not_to satisfy '= 2.3.3' }
      it { is_expected.not_to satisfy '= 2.3.4' }
      it { is_expected.not_to satisfy '= 2.3.5' }
      it { is_expected.not_to satisfy '= 2.4' }
      it { is_expected.not_to satisfy '= 3' }
      it { is_expected.not_to satisfy '= 3.1' }
      it { is_expected.not_to satisfy '= 3.1.1' }
    end

    describe '2.3' do
      let(:version) { '2.3' }

      it { is_expected.not_to satisfy '= 1' }
      it { is_expected.not_to satisfy '= 1.1' }
      it { is_expected.not_to satisfy '= 1.1.1' }
      it { is_expected.to     satisfy '= 2' }
      it { is_expected.to     satisfy '= 2.3' }
      it { is_expected.not_to satisfy '= 2.3.3' }
      it { is_expected.not_to satisfy '= 2.3.4' }
      it { is_expected.not_to satisfy '= 2.3.5' }
      it { is_expected.not_to satisfy '= 2.4' }
      it { is_expected.not_to satisfy '= 3' }
      it { is_expected.not_to satisfy '= 3.1' }
      it { is_expected.not_to satisfy '= 3.1.1' }
    end

    describe '2.3.3' do
      let(:version) { '2.3.3' }

      it { is_expected.not_to satisfy '= 1' }
      it { is_expected.not_to satisfy '= 1.1' }
      it { is_expected.not_to satisfy '= 1.1.1' }
      it { is_expected.to     satisfy '= 2' }
      it { is_expected.to     satisfy '= 2.3' }
      it { is_expected.to     satisfy '= 2.3.3' }
      it { is_expected.not_to satisfy '= 2.3.4' }
      it { is_expected.not_to satisfy '= 2.3.5' }
      it { is_expected.not_to satisfy '= 2.4' }
      it { is_expected.not_to satisfy '= 3' }
      it { is_expected.not_to satisfy '= 3.1' }
      it { is_expected.not_to satisfy '= 3.1.1' }
    end
  end

  describe '!=' do
    describe '2.3.2' do
      let(:version) { '2.3.2' }

      it { is_expected.to     satisfy '!= 1' }
      it { is_expected.to     satisfy '!= 1.1' }
      it { is_expected.to     satisfy '!= 1.1.1' }
      it { is_expected.not_to satisfy '!= 2' }
      it { is_expected.not_to satisfy '!= 2.3' }
      it { is_expected.to     satisfy '!= 2.3.3' }
      it { is_expected.to     satisfy '!= 2.3.4' }
      it { is_expected.to     satisfy '!= 2.3.5' }
      it { is_expected.to     satisfy '!= 2.4' }
      it { is_expected.to     satisfy '!= 3' }
      it { is_expected.to     satisfy '!= 3.1' }
      it { is_expected.to     satisfy '!= 3.1.1' }
    end

    describe '2.3.4' do
      let(:version) { '2.3.4' }

      it { is_expected.to     satisfy '!= 1' }
      it { is_expected.to     satisfy '!= 1.1' }
      it { is_expected.to     satisfy '!= 1.1.1' }
      it { is_expected.not_to satisfy '!= 2' }
      it { is_expected.not_to satisfy '!= 2.3' }
      it { is_expected.to     satisfy '!= 2.3.3' }
      it { is_expected.not_to satisfy '!= 2.3.4' }
      it { is_expected.to     satisfy '!= 2.3.5' }
      it { is_expected.to     satisfy '!= 2.4' }
      it { is_expected.to     satisfy '!= 3' }
      it { is_expected.to     satisfy '!= 3.1' }
      it { is_expected.to     satisfy '!= 3.1.1' }
    end
  end
end
