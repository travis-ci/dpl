require 'dpl2/provider'

module Dpl
  module Providers
    class BitBalloon < Provider
      summary 'BitBallon deployment provider'

      description <<~str
        BitBallon provides free simple static site hosting.

        This deployment provider helps you deploy to BitBallon easily.
      str

      opt '--local_dir DIR',       'The sub-directory of the built assets for deployment', default: '.'
      opt '--site_id ID',          'The side id'
      opt '--access_token TOKEN',  'The access token'

      def cmd
        cmd = ['bitballoon deploy', local_dir]
        cmd << "--site-id=#{site_id}"           if site_id?
        cmd << "--access-token=#{access_token}" if access_token?
        cmd.compact.join(' ')
      end
    end
  end
end
