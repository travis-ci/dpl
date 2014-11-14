require 'dpl/version'

module DPL
  class Provider
    module Heroku
      class Git < Generic
        require 'netrc'

        def git_url
          "https://git.heroku.com/#{option(:app)}.git"
        end

        def push_app
          git_remote = options[:git] || git_url
          write_netrc if git_remote.start_with?("https://")
          ENV['GIT_HTTP_USER_AGENT'] = git_user_agent
          context.shell "git push #{git_remote} HEAD:refs/heads/master -f"
        end

        def write_netrc
          n = Netrc.read
          n['git.heroku.com'] = [user, option(:api_key)]
          n.save
        end

        def git_user_agent
          ua_info          = {}
          ua_info[:travis] = "0.1.0" if ENV['TRAVIS']
          ua_info[:dpl]    = DPL::VERSION
          ua_info[:git]    = `git --version`[/[\d\.]+/]
          ua_info.map { |k,v| "#{k}/#{v}" }.join(" ")
        end
      end
    end
  end
end
