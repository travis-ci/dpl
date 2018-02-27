module DPL
    class Provider
      class Now < Provider
        npm_g 'now'
  
        def directory
          File.expand_path( (context.env['TRAVIS_BUILD_DIR'] || '.' ) + '/' + (options[:directory] || '') )
        end
  
        def deploy_name
          options[:deploy_name]
        end
  
        def team
          if options[:team]
            log "> Adding custom team scope #{options[:team]}"
            now_team_option = "--team #{options[:team]}"
          else
            now_team_option = ''
            log '> No custom team scope provided.'
          end

          return now_team_option
        end
  
        def type
          options[:type]
        end
  
        def alias_url
          options[:alias]
        end
  
        def cleanup
          options[:cleanup]
        end
  
        def scale
          options[:scale]
        end

        def rules_domain
          options[:rules_domain]
        end

        def rules_file
          options[:rules_file]
        end
  
        def token
          context.env['NOW_TOKEN']
        end

        def auth
          return "--token #{token} #{team}"
        end

        def deploy_options
          now_deploy_options = '--no-clipboard'
          if deploy_name
            log "> Adding deployment name #{deploy_name}"
            now_deploy_options = now_deploy_options + " --name #{deploy_name}"
          else
            log '> No deployment name provided. The directory will be used as the name'
          end

          if type
            log "> Adding deployment type #{type}"
            now_deploy_options = now_deploy_options + " --#{type}"
          else
            log '> No deployment type provided, now.sh will try to detect it...'
          end

          return now_deploy_options
        end

        def aliasing(deployment_url)
          if alias_url
            log '> Assigning alias…'
            context.shell "now alias #{auth} #{deployment_url} #{alias_url}"
            deployment_url = "https://#{alias_url}"
          else
            log '> No alias provided'
          end
          return deployment_url
        end

        def check_auth
          if ! token then raise Error, '> Error!! Please add NOW_TOKEN Environment Variables in Travis settings (get your token here https://zeit.co/account/tokens)' end
        end
  
        def check_app
          if ! File.directory?(directory) then raise Error, 'Please set a valid project folder path in .travis.yml under deploy: directory: myPath' end
          if cleanup && !alias_url then raise Error, 'You must set the alias parameter when using the cleanup parameter so that now.sh knows which deployments to remove!' end
          if ((rules_domain && !rules_file) || rules_file && !rules_domain) then raise Error, 'You must set the rules_domain and rules_file parameters in order to set custom domain rules' end
        end
  
        def needs_key?
          false
        end
  
        def push_app
          log "> Deploying #{directory} on now.sh…"
          deployment_url = `now #{auth} #{deploy_options} #{directory}`
          log "> Success! Deployment complete to #{deployment_url}"

          deployment_url = aliasing(deployment_url)

          if cleanup
            log '> Cleaning up old deployments…'
            cleanup_success_message = `now rm --safe --yes #{auth} #{alias_url}`
            log cleanup_success_message
          end

          if scale
            log '> Scaling…'
            scale_success_message = `now scale #{auth} #{deployment_url} #{scale}`
            log scale_success_message
          end

          if rules_domain
            log '> Assigning domain rules…'
            rules_success_message = `now alias #{auth} #{rules_domain} -r #{rules_file}`
            log rules_success_message
          end

          if $?.exitstatus != 0
            raise Error, "> Now deployment failed with status #{$?.exitstatus}"
          else
            log "> Successfully deployed! #{deployment_url}"
          end
        end
      end
    end
  end
  