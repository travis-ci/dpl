module DPL
    class Provider
      class Netlify < Provider
        GIMME_URL = 'https://raw.githubusercontent.com/meatballhat/gimme/master/gimme'
        NETLIFY_CTL_GO_REMOTE = 'github.com/netlify/netlifyctl'
        NETLIFY_INSTALL_SCRIPT = <<-EOF.gsub(/^ {8}/, '').strip
          if ! command -v netlifyctl &>/dev/null ; then
            mkdir -p $HOME/bin $HOME/gopath/src
            export PATH="$HOME/bin:$PATH"
  
            if ! command -v gimme &>/dev/null ; then
              curl -sL -o $HOME/bin/gimme #{GIMME_URL}
              chmod +x $HOME/bin/gimme
            fi
  
            if [ -z $GOPATH ]; then
              export GOPATH="$HOME/gopath"
            else
              export GOPATH="$HOME/gopath:$GOPATH"
            fi
            eval "$(gimme 1.6)" &> /dev/null
  
            go get #{NETLIFY_CTL_GO_REMOTE}
            cp $HOME/gopath/bin/netlifyctl $HOME/bin/netlifyctl
          fi
        EOF
  
        def token
          context.env['NETLIFY_TOKEN']
        end
  
        def site_id
          context.env['NETLIFY_SITE_ID']
        end

        def directory
          File.expand_path( (context.env['TRAVIS_BUILD_DIR'] || '.' ) + '/' + (options[:directory] || '') )
        end

        def auth
          "-A #{token}"
        end

        def deploy_options
          netlify_deploy_options = "-b #{directory}"
          return netlify_deploy_options
        end

        def check_auth
          if ! token || ! site_id then raise Error, '> Error!! Please add NETLIFY_TOKEN & NETLIFY_SITE_ID Environment Variables in Travis settings (get it here https://app.netlify.com/applications)' end
        end
  
        def check_app
          if ! File.directory?(directory) then raise Error, '> Error!! Please set a valid project folder path in .travis.yml under deploy: directory: myPath' end
        end
  
        def needs_key?
          false
        end
  
        def push_app
          log '> Deploying on Netlify...'
          error '> Error!! Failed to deploy' unless context.shell "netlifyctl deploy -y #{auth} -s #{site_id} #{deploy_options}"

          log "\n\n> Successfully deployed!"
        end

        def deploy
          install_netlifyctl
          super
        end

        def install_netlifyctl
          without_git_http_user_agent do
            context.shell NETLIFY_INSTALL_SCRIPT
          end
        end

        def without_git_http_user_agent(&block)
          git_http_user_agent = ENV.delete("GIT_HTTP_USER_AGENT")
          yield
          ENV["GIT_HTTP_USER_AGENT"] = git_http_user_agent
        end
      end
    end
  end
  