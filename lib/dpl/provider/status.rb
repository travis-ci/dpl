module Dpl
  class Provider < Cl::Cmd
    class Status < Struct.new(:provider, :status, :info)
      STATUS = %i(dev alpha beta stable deprecated)

      MSG = {
        dev:        'Support for %s is in development',
        alpha:      'Support for %s is in alpha',
        beta:       'Support for %s is in beta',
        deprecated: 'Support for %s is deprecated',
        pre_stable: 'Please see our documentation on maturity statuses: %s'
      }

      DOCS = 'https://docs.travis-ci.com/user/deployment/#maturity-status'

      def initialize(provider, status, info)
        unknown!(status) unless known?(status)
        super
      end

      def announce?
        !stable?
      end

      def announce
        [log_level, msg]
      end

      private

        def log_level
          deprecated? ? :warn : :info
        end

        def msg
          msg = "#{MSG[status] % name}"
          msg << "(#{info})" if info
          msg << ". #{MSG[:pre_stable] % DOCS}" if pre_stable?
          msg
        end

        def name
          provider.full_name
        end

        def pre_stable?
          STATUS.index(status) < STATUS.index(:stable)
        end

        def stable?
          status == :stable
        end

        def deprecated?
          status == :deprecated
        end

        def known?(status)
          STATUS.include?(status)
        end

        def unknown!(status)
          raise "Unknown status: #{status.inspect}. Known statuses are: #{STATUS.map(&:inspect).join(', ')}"
        end
    end
  end
end
