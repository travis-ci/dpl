# Changelog

## dpl v2.0.3-beta.1 (2022-03-15)

* Deprecate support for Ruby 2.2

## dpl v2.0.2-beta.1 (2020-09-15)

* Add AWS ECR support

## dpl v2.0.1-beta.3 (unreleased)

* Change git_push to use the GitHub token's user name and email as the
  committer name and email

## dpl v2.0.1-beta.2 (2020-01-27)

* Change codedeploy, lambda, and pages to safelist variables available for
  interpolation on user facing options

## dpl v2.0.1-beta.1 (2020-01-27)

* No changes

## dpl v2.0.0-alpha.13 (2020-01-17)

* Add s3 `--glob`

## dpl v2.0.0-alpha.13 (2020-01-06)

* Bump Cl which now raises on arguments undeclared by the command

## dpl v2.0.0-alpha.12 (2020-01-06)

* Add npm `--run_script`, allowing one or many scripts from package.json to be run
* Add elasticbeanstalk `--wait_until_deployed_timeout`
* Update pages to pass one -m option per commit message line
* Fix releases to transliterate filenames in an attempt to mirror GitHub's behavior

## dpl v2.0.0-alpha.11 (2019-10-14)

* Fix pages: do not skip if new or only deleted files are present

## dpl v2.0.0-alpha.6 - v2.0.0-alpha.10 (2019-10-09)

* Add a Cloudformation provider
* Add a Convox provider
* Add a Gleis provider
* Remove the Atlas provider (service retired)
* Rescue `UnknownOption` and suggest known options on Ruby >= 2.4
* Allow options to be given as env vars on all providers

### Cargo

* Add `--allow_dirty` to allow publishing from a dirty Git working directory

### Cloudfoundry

* Default `--api` to `https://api.run.pivotal.io`

### Elasticbeanstalk

* Hornor `.gitignore` if `.ebignore` is not present

### GCS

* Add `--key_file` to allow using a service account key file

### NPM

* Allow publishing to GitHub Package Registry
* Add `--dry_run` to allow testing deployments

### Pages

* Do not commit or push unless the working dir is dirty on cloned repos

### Releases

* Make --file glob files by default, and default to `*`

## dpl v2.0.0-alpha.2 (2019-08-28)

* Add `--edge` as an internal flag in case `edge: true` was given in `.travis.yml`

## dpl v2.0.0-alpha.1 (2019-08-27)

* Default to not cleaning the git working directory, but accept `--cleanup` in order to clean up the git working directory.
* Support a maturity model using dev, alpha, beta, stable.
* Use Ruby's `DidYouMean` in order to suggest provider names if the given name is not valid.
* Use `~/.dpl` rather than `./.dpl` as a directory to store assets, and remove `~/.dpl` before the process terminates.
* Use the AWS SDK v3 for AWS providers.
* Fix git-ssh to work with non-standard ssh ports (used by all providers that rely on Git).

### bintray

* List files in the downloads list if specified in the descriptor file.

### chef-supermarket

* Read the cookbook name a given metadata.json or metadata.rb file if not given as `--name`.
* Use `--name` and `--category`, but keep `--cookbook_name` and `--cookbook_category` as deprecated aliases.

### cloudfoundry

* Accept `--v3` in order to use the `v3-push` command.

### codedeploy

* Accept `--file_exist_behavior` in order to specify how to handle files that already exist in a deployment target location.

### elasticbeanstalk

* Accept `--label` and `--description` in order to define these attributes.
* Remove non-printable unicode chars from the version description.
* Accept `--debug` in order to list files added to the zip archive.
* Honor `.ebignore` in order to exclude files from being added to the zip file.

### engineyard

* Use `ey-core` as CLI tooling.

### firebase

* Accept `--only` in order to restrict the resources to deploy.
* Accpet `--force` in order to delete functions missing from the current working directory.
* Add `node_modules/.bin` to the `PATH` in case users have `firebase` in that directory.

### gae

* Accept multiple values on on `--config`.

### hackage

* Accept `--publish` in order to publish a package.

### lambda

* Accept `--layers` to deploy function layers.
* Do not require a role and handler name when functions are only being updated.
* Use the correct handler name separators for dotnet, go, and java runtimes.

### npm

* Accept `--registry` in order to specify the target registry.
* Accept `--src` in order to specify a directory or tarball to publish.
* Accept `auth` as an `--auth_method` in order to force writing the token to `_auth` in `~/.npmrc`.

### pages

* Accept a `--deploy_key` as an alternative to the GitHub token (expects a path to a file).
* Accept a commit message on `--commit_message`, allow interpolating variables (e.g. as `$TRAVIS_BUILD_NUMBER`).
* Check if the target branch already exists and preserves git history by default. `--no-keep_history` can be passed in order to erase history on the target branch.
* Include symbolic links.
* Add an alternative strategy for deploying via GitHub's pages HTTP API

### pypi

* Accept `--no-remove_build_dir` in order to skip removing the build dir (`./dist`).
* Run `twine check dist/*` by default, and accept `--no-twine_check` for opting out.

### releases

* Accept a path to a file containing release notes on `--release_notes_file`.
* Use `--release_notes` for passing the release notes content, keep `--body` as a deprecated alias.

### s3

* Accept `--no-overwrite` in order to not overwrite existing files.
* Accept `--force_path_style` in order to use the bucket name on the path, rather than the subcomain
* Print out dots instead of filenames by default, and accept `--verbose` for printing out all filenames uploaded.
* Use `application/octet-stream` as a default content type if a content type cannot be determined.
