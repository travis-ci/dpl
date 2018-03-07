require 'bitballoon'

module DPL
  class Provider
    class BitBalloon < Provider
      def check_auth
      end

      def needs_key?
        false
      end

      def push_app
        command = 'bitballoon deploy'
        command << " ./#{option(:local_dir)}" if options.fetch(:local_dir,false)
        command << " --site-id=#{option(:site_id)}" if options[:site_id]
        command << " --access-token=#{option(:access_token)}" if options[:access_token]
        context.shell command
      end
    end
  end
end
