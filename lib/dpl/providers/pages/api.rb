require 'timeout'
require 'octokit'

module Dpl
  module Providers
    class Pages
      class Api < Pages
        PAGES_PREVIEW_MEDIA_TYPE = 'application/vnd.github.mister-fantastic-preview+json'

        # suppress warnings about preview API
        ENV['OCTOKIT_SILENT'] = 'true'

        TIMEOUTS = {
          timeout: 180,
          open_timeout: 180
        }

        gem 'octokit', '~> 4.14.0'

        status :alpha

        full_name 'GitHub Pages using API'

        description sq(<<-str)
          tbd
        str

        msgs pages_not_found:             'GitHub Pages not found for %{slug}. ' \
               'Given token has insufficient scope (\'repo\' or \'public_repo\'), ' \
               'or GitHub Pages is not enabled for this repo (see https://github.com/%{slug}/settings)',
             build_pages_request_timeout: 'GitHub Pages build request timed out',
             deploy_start:                'Requesting GitHub Pages build using API',
             branch_name_mismatch:        'The current git branch \'%s\' does not match GitHub Pages branch \'%s\''

        def validate
          ::Octokit.default_media_type = PAGES_PREVIEW_MEDIA_TYPE

          error :pages_not_found unless pages_enabled?

          unless git_branch == pages_branch
            error :branch_name_mismatch, git_branch, pages_branch
          end
        end

        def deploy
          info :deploy_start

          api.request_page_build slug

          response = api.pages slug
          logger.debug response

          Timeout::timeout(30) do
            until response.status == 'built'
              response = api.pages slug
              logger.debug response
              sleep 1
            end
          end

          latest_pages_build = api.latest_pages_build slug
          if msg = latest_pages_build.error.message
            error "Build failed: #{msg}"
          end

          info "Pages deployed to #{response.html_url}, using commit #{latest_pages_build.commit}"
          logger.debug latest_pages_build

        rescue Octokit::Forbidden => fb
          error fb.message
        rescue Timeout::Error => to
          error :build_pages_request_timeout
        end

        private

        def slug
          repo || repo_slug
        end

        def user
          @user ||= api.user
        end

        def pages
          @pages ||= api.pages slug
        end

        def api
          @api ||= Octokit::Client.new(**creds, auto_paginate: true, connection_options: { request: TIMEOUTS })
        end

        def pages_branch
          pages.source.branch
        end

        def creds
          { access_token: github_token }
        end

        def pages_enabled?
          api.pages slug
        rescue Octokit::NotFound => e
          error :pages_not_found
        end

      end
    end
  end
end
