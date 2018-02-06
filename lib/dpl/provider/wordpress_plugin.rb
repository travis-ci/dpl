module DPL
  class Provider
    class WordpressPlugin < Provider
      require 'tmpdir'

      SVN_URL = 'https://plugins.svn.wordpress.org/{{slug}}'.freeze

      experimental 'WordPress Plugin'

      def needs_key?
        false
      end

      def check_auth
        log 'Finding configuration for WordPress plugin deployment...'
        log "Slug: #{slug}"
        log "Username: #{username}"
        log 'Password found' unless password.to_s.empty?
        log "Build Directory: #{build_dir}"
        log "Assets Directory: #{assets_dir || 'not found'}"
      end

      def check_app
        log 'Validating configuration for WordPress plugin deployment...'

        check_build_dir
        check_assets_dir if assets_dir
        check_tag

        log 'Configuration looks good'
        log "Going to deloy tag: #{tag}"
      end

      def push_app
        Dir.mktmpdir do |tmpdir|
          push_svn tmpdir
        end
      end

      private

      def push_svn tmpdir
        svn_checkout tmpdir
        if svn_tag_exist? tmpdir
          warn "Tag already exists on subversion server for version #{tag}"
          return
        end

        clear "#{tmpdir}/trunk"
        clear "#{tmpdir}/assets" if assets_dir

        # This is necessary to prevent `containing working copy admin area is
        # missing` errors because Travis container runs a older version of subversion
        svn_delete tmpdir
        svn_commit 'Temporary removing trunk and assets(if assets_dir is set)', tmpdir

        copy build_dir, "#{tmpdir}/trunk"
        copy "#{tmpdir}/trunk", "#{tmpdir}/tags/#{tag}"
        copy assets_dir, "#{tmpdir}/assets" if assets_dir

        svn_add tmpdir
        svn_commit "Committing #{tag}", tmpdir
      end

      def svn_checkout tmpdir
        log "Checking out #{svn_url}"

        context.shell "svn co --quiet --non-interactive #{svn_url} #{tmpdir}"
      end

      def svn_tag_exist? tmpdir
        Dir.exist?("#{tmpdir}/tags/#{tag}")
      end

      def clear dir
        log "Clearing #{dir}..."

        FileUtils.rm_rf dir
      end

      def copy source, dest
        log "Copying #{source} to #{dest}..."

        FileUtils.mkdir_p dest
        FileUtils.cp_r "#{source}/.", dest
      end

      def svn_add tmpdir
        log 'Adding new files to subversion...'

        context.shell "svn status #{tmpdir} | grep '^?' | awk '{print $2}' | xargs -I x svn add x@"
      end

      def svn_delete tmpdir
        log 'Removing deleted files from subversion...'

        context.shell "svn status #{tmpdir} | grep '^!' | awk '{print $2}' | xargs -I x svn delete --force x@"
      end

      def svn_commit message, tmpdir
        log message

        context.shell "svn commit --no-auth-cache --non-interactive --username '#{username}' --password '#{password}' #{tmpdir} -m '#{message}'"
      end

      def check_build_dir
        error 'Build directory does not exist' unless Dir.exist?(build_dir)
      end

      def check_assets_dir
        error 'Assets directory is set but not exist' unless Dir.exist?(assets_dir)
      end

      def check_tag
        error 'Unable to determine tag version' if tag.empty?
      end

      def slug
        @slug ||= context.env['WORDPRESS_PLUGIN_SLUG'] || option(:slug)
      end

      def username
        @username ||= context.env['WORDPRESS_PLUGIN_USERNAME'] || option(:username)
      end

      def password
        @pasword ||= context.env['WORDPRESS_PLUGIN_PASSWORD'] || option(:password)
      end

      def build_dir
        @build_dir ||= context.env['WORDPRESS_PLUGIN_BUILD_DIR'] || option(:build_dir)
      end

      def assets_dir
        @assets_dir ||= context.env['WORDPRESS_PLUGIN_ASSETS_DIR'] || options[:assets_dir]
      end

      def svn_url
        @svn_url ||= SVN_URL.gsub '{{slug}}', slug
      end

      def tag
        @tag ||= if travis_tag.empty?
                   `git describe --tags --exact-match 2>/dev/null`.chomp
                 else
                   travis_tag
                 end
      end

      def travis_tag
        context.env['TRAVIS_TAG'].to_s
      end
    end
  end
end
