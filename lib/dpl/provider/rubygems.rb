module DPL
  class Provider
    class RubyGems < Provider
      requires 'gems', version: '>= 0.8.3'

      def setup_auth
        ::Gems.key = option(:api_key) if options[:api_key]
        ::Gems.username = option(:user) unless options[:api_key]
        ::Gems.password = option(:password) unless options[:api_key]
      end

      def needs_key?
        false
      end

      def setup_gem
        options[:gem] ||= options[:app]
      end

      def gemspec
        options[:gemspec].gsub('.gemspec', '') if options[:gemspec]
      end

      def check_app
        setup_auth
        setup_gem
        info = ::Gems.info(options[:gem])
        log "Found gem #{info['name']}"
      end

      def check_auth
        setup_auth
        log "Authenticated with username #{::Gems.username}" if ::Gems.username
      end

      def push_app
        setup_auth
        setup_gem
        context.shell "gem build #{gemspec || option(:gem)}.gemspec"
        Dir.glob("#{gemspec || option(:gem)}-*.gem") do |f|
          if options[:host]
            log ::Gems.push(File.new(f), options[:host])
          else
            log ::Gems.push(File.new f)
          end
        end
      end
    end
  end
end
