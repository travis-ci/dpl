
    def cleanup
      return if options[:skip_cleanup]
      context.shell "mv .dpl ~/dpl"
      log "Cleaning up git repository with `git stash --all`. " \
        "If you need build artifacts for deployment, set `deploy.skip_cleanup: true`. " \
        "See https://docs.travis-ci.com/user/deployment#Uploading-Files-and-skip_cleanup."
      context.shell "git stash --all"
      context.shell "mv ~/dpl .dpl"
    end

    def uncleanup
      return if options[:skip_cleanup]
      context.shell "git stash pop"
    end
