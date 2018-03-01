require 'open3'

module DPL
  class Provider
    class Snap < Provider
      apt_get 'snapd', 'snap'
      snap 'snapcraft', classic: true

      def install_deploy_dependencies
        # Snapcraft may already be installed, but in case we installed
        # the snap, we need to add /snap/bin to the PATH.
        ENV["PATH"] += ':/snap/bin'
      end

      def check_auth
        log "Attemping to login"
        stdout, stderr, status = Open3.capture3(
          "snapcraft login --with -", stdin_data: login_token)

        if status == 0
          log stdout
        else
          error "Failed to authenticate: #{stderr}"
        end
      end

      # No SSH keys needed
      def needs_key?
        false
      end

      # Users must specify the path to the snap they want pushed (globbing is
      # supported).
      def snap
        options[:snap] || error("Missing snap")
      end

      # Users can specify the channel into which they'd like to release this
      # snap. It defaults to the 'edge' channel.
      def channel
        options[:channel] || 'edge'
      end

      # Users must specify their login token, either explicitly in the YAML or
      # via the $SNAP_TOKEN enironment variable.
      def login_token
        options[:token] || context.env['SNAP_TOKEN'] || error("Missing token")
      end

      def push_app
        snaps = Dir.glob(snap)
        if snaps.length > 1
          snap_list = snaps.join(', ')
          error "Multiple snaps found matching '#{snap}': #{snap_list}"
        end

        snap_path = snaps.first
        if snap_path.nil?
          error "No snap found matching '#{snap}'"
        end

        context.fold("Pushing snap") do
          context.shell "snapcraft push #{snap_path} --release=#{channel}"
        end
      end
    end
  end
end
