module DPL
  class Provider
    module Heroku
      class GitSSH < Git
        def git_url
          info['git_url']
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
