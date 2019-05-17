module Dpl
  module Providers
    class BitBalloon < Provider
      gem 'bitballoon', '~> 0.2.6'

      description sq(<<-str)
        BitBallon provides free simple static site hosting.

        This deployment provider helps you deploy to BitBallon easily.
      str

      opt '--access_token TOKEN', 'The access token', required: true
      opt '--site_id ID',         'The side id', required: true
      opt '--local_dir DIR',      'The sub-directory of the built assets for deployment', default: '.'

      def deploy
        shell "bitballoon deploy #{local_dir} #{deploy_opts}"
      end

      private

        def deploy_opts
          opts_for(%i(site_id access_token), dashed: true)
        end
    end
  end
end
