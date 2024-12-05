# frozen_string_literal: true

require 'timeout'

module Dpl
  module Providers
    class Pages
      class Api < Pages
        register :'pages:api'

        status :dev

        PAGES_PREVIEW_MEDIA_TYPE = 'application/vnd.github.mister-fantastic-preview+json'

        # suppress warnings about preview API
        ENV['OCTOKIT_SILENT'] = 'true'

        TIMEOUTS = {
          timeout: 180,
          open_timeout: 180
        }.freeze

        gem 'octokit', '~> 7'
        gem 'timeout', '0.4.1'

        full_name 'GitHub Pages (API)'

        description sq(<<-STR)
          This provider requests GitHub Pages build for the repository given by
          the `--repo` flag, or the current one, if the flag is not given.
          Note that `dpl` does not perform any check about the fitness of the request;
          it is assumed that the target repository (and the branch that GitHub Pages is
          configured to use) is ready for building.
          For example, if your GitHub Pages is configured to use `gh-pages` but the
          deployment is run on the `master` branch, you would have to ensure that the
          `gh-pages` would be updated accordingly during the build.
        STR

        opt '--repo SLUG', 'GitHub repo slug', default: :repo_slug
        opt '--token TOKEN', 'GitHub oauth token with repo permission', required: true, secret: true, alias: :github_token

        msgs not_found: sq(<<-MSG),
               GitHub Pages not found for %{slug}.
               Either the given token has insufficient scope (repo or public_repo), or
               GitHub Pages is not enabled for this repo (see https://github.com/%{slug}/settings)'
        MSG
             timeout: 'GitHub Pages build request timed out',
             deploy: 'Requesting GitHub Pages build using API'

        def validate
          error :not_found unless pages_enabled?
        end

        def deploy
          info :deploy

          api.request_page_build slug

          response = api.pages slug
          logger.debug response

          Timeout.timeout(30) do
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
        rescue Octokit::Forbidden => e
          error e.message
        rescue Timeout::Error
          error :timeout
        end

        private

        def slug
          repo || repo_slug
        end

        def api
          ::Octokit.default_media_type = PAGES_PREVIEW_MEDIA_TYPE unless @api

          @api ||= Octokit::Client.new(**creds, auto_paginate: true, connection_options: { request: TIMEOUTS })
        end

        def creds
          { access_token: token }
        end

        def pages_enabled?
          api.pages slug
        rescue Octokit::NotFound
          false
        end
      end
    end
  end
end
