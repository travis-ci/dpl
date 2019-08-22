# Changelog

## dpl v2.0.0-alpha.1 (eta 2019-08-28)

* default to not cleaning the git working directory, but accept `--cleanup` in order to clean up the git working directory
* support a maturity model using dev, alpha, beta, stable
* use Ruby's `DidYouMean` in order to suggest provider names if the given name is not valid
* use `~/.dpl` rather than `./.dpl` as a directory to store assets, and remove `~/.dpl` before the process terminates
* use the AWS SDK v3 for AWS providers
* fix git-ssh to work with non-standard ssh ports (used by all providers that rely on Git)

### bintray
* list files in the downloads list if specified in the descriptor file

### chef-supermarket
* read the cookbook name a given metadata.json or metadata.rb file if not given as `--name`
* use `--name` and `--category`, but keep `--cookbook_name` and `--cookbook_category` as deprecated aliases

### cloudfoundry
* accept `--v3` in order to use the `v3-push` command

### codedeploy
* accept `--file_exist_behavior` in order to specify how to handle files that already exist in a deployment target location

### elasticbeanstalk
* accept `--label` and `--description` in order to define these attributes
* remove non-printable unicode chars from the version description
* accept `--debug` in order to list files added to the zip archive
* honor `.ebignore` in order to exclude files from being added to the zip file

### engineyard
* uses `ey-core` as CLI tooling

### firebase
* accept `--only` in order to restrict the resources to deploy
* accpet `--force` in order to delete functions missing from the current working directory
* add `node_modules/.bin` to the `PATH` in case users have `firebase` in that directory

### gae
* accept multiple values on on `--config`

### hackage
* accept `--publish` in order to publish a package

### lambda
* accept `--layers` to deploy function layers
* do not require a role and handler name when functions are only being updated
* use the correct handler name separators for dotnet, go, and java runtimes

### npm
* accept `--registry` in order to specify the target registry
* accept `--src` in order to specify a directory or tarball to publish
* accept `auth` as an `--auth_method` in order to force writing the token to `_auth` in `~/.npmrc`

### pages
* accept a `--deploy_keys` as an alternative to the GitHub token
* accept a commit message on `--commit_message`, allow interpolating variables (e.g. as `$TRAVIS_BUILD_NUMBER`).
* check if the target branch already exists and preserves git history by default. `--no-keep_history` can be passed in order to erase history on the target branch.
* include symbolic links

### pypi
* accept `--no-remove_build_dir` in order to skip removing the build dir (./dist)
* run `twine check dist/*` by default, and accept `--no-twine_check` for opting out

### releases
* accept a path to a file containing release notes on `--release_notes_file`
* use `--release_notes` for passing the release notes content, keep `--body` as a deprecated alias

### s3
* accept `--no-overwrite` in order to not overwrite existing files
* print out dots instead of filenames by default, and accept `--verbose` for printing out all filenames uploaded
* use `application/octet-stream` as a default content type if a content type cannot be determined
