# Dpl 2.0

Dpl 2.0 is the next major version of our deployment tooling, and basically
a rewrite of the current codebase.

We are looking for contributors or subject matter experts to help us test
and/or improve all deployment providers/services.

The goal is to:

* Run at least one deployment manually using the new version, provide a link to
  the respective build.
* Implement an automated test that deploys to the respective service that can
  run on Travis CI.

## Automated tests

We have added automated integration tests for the providers/services we are
familiar with. These live in https://github.com/travis-ci/dpl/tree/dpl-2/.travis.
They actually make a deployment to the respective service (or in case of
Rubygems to a service running locally). The are currently triggered manually,
and may be run on a regular basis in the future (as a cron build).

A provider test consists of:

* A setup script that creates an application (or artifact) to deploy (or
  upload).
* A YAML config snippet that configures and triggers the deployment as part of
  a build on Travis CI.
* A test script that tests if the deployment was successful.

For example:

* [github_pages_prepare](https://github.com/travis-ci/dpl/blob/dpl-2/.travis/providers/github_pages_prepare)
  creates a minimal Git repository that serves an `index.html` on GitHub Pages in a temporary directory.
* [github_pages.yml](https://github.com/travis-ci/dpl/blob/dpl-2/.travis/providers/github_pages.yml)
  configures the build to use Dpl 2.0 to deploy this repository to GitHub Pages.
* [github_pages_test](https://github.com/travis-ci/dpl/blob/dpl-2/.travis/providers/github_pages_test)
  tests if the deployment was successful.

The tests can be run on Travis CI individually, or combined, by triggering a
build via our API, using the script [.travis/trigger](https://github.com/travis-ci/dpl/blob/dpl-2/.travis/trigger).
This takes a provider name as an argument, and requires a Travis CI API token
to be given.

For example, this triggers a build that executes the GitHub Pages test on
Travis CI:

```
.travis/trigger github_pages --token [token]
```

The token can also be set as an environment variable:

```
export TRAVIS_API_TOKEN=[token]
.travis/trigger github_pages
```

The `trigger` script accepts multiple provider names as arguments. If no
arguments are given then tests for all providers will be run.

## How to contribute a test

Fork this repository, work off the branch [dpl-2](https://github.com/travis-ci/dpl/pull/1003) (not the master branch).

Go to your Travis CI account page, sync your account, and enable the repository.

Implement a provider test.

In the build config YAML snippet make sure to use the branch of your fork for the
deployment tooling, and allow the deployment to run on your branch:

```
deploy:
  - provider: [name]
    edge:
      source: [your-login]/dpl
      branch: dpl-2
    on:
      branch: [your-branch]
```

Ideally use credentials for an isolated account on the service you are deploying to.
This is generally good practice, and way you can hand things off to someone else.

In order to get things working encrypt the credentials against your fork, and
add them to the build config YAML snippet. If you are standing in the root directory
of your fork then this command should do the trick:

```
travis encrypt password=[password]
```

If you do not have the `travis` CLI installed you can install it using:

```
gem install travis
```

When you add encrypted credentials to the build config YAML snippet also add a comment
that allows others to identify the account used. E.g:

```
deploy:
  - provider: pages
    github_token:
      # personal access token with repo scope on the account [name]
      secure: "[encrypted token]"
```

Open a pull request. In order for us to merge your test, and get it working on
our repository you will need to re-encrypt the credentials against
`travis-ci/dpl`, like so:

```
travis encrypt -r travis-ci/dpl password=[password]
```

Whatever minimal deployment you can get working would be a great contribution.
Even if for some reason it proves hard to test the deployment in an automated
fashion, but you have a successful deployment that can be verified manually,
please still open a pull request, and talk to us. Any test is better than no
test.

## How to get in touch

Feel free to reach out to us via email to success@travis-ci.com. Please include
the tag `[dpl-2]` to the subject line, so our inbox directs your email to the
right team.

We also have a shared Slack channel for more direct communication that we'd
love to add you to.

