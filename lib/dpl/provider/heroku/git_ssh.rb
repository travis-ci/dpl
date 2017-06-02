module DPL
  class Provider
    module Heroku
      class GitSSH < Git
        puts ''
        puts "\e[31;1mgit-ssh strategy is deprecated, and will be shut down on June 26, 2017.\e[0m"
        puts "\e[31;1mPlease consider moving to the \`api\` or \`git\` strategy.\e[0m"
        puts ''

        def git_url
          @app['git_url']
        end

        def needs_key?
          true
        end

        def setup_key(file)
          api.post_key File.read(file)
        end

        def remove_key
          api.delete_key(option(:key_name))
        end
      end
    end
  end
end
