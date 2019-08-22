# Changelog

## dpl v2.0.0-alpha.1 (eta 2019-08-28)

* defaults to not cleaning the git working directory. users who need to clean up their git working directory need to opt in using `--cleanup`
* supports a maturity model using dev, alpha, beta, stable
* uses Ruby's `DidYouMean` in order to suggest provider names if the given name is not valid
* uses `~/.dpl` rather than `./.dpl` as a directory to store assets, and removes `~/.dpl` before the process terminates
* uses the AWS SDK v3 for AWS providers
* fixed git-ssh to work with non-standard ssh ports (used by all providers that rely on Git)

### bintray
* lists files in the downloads list if specified in the descriptor file

### chef-supermarket
* reads the cookbook name a given metadata.json or metadata.rb file if not given as `--name`
* uses `--name` and `--category`, `--cookbook_name` and `--cookbook_category` are still accepted as deprecated aliases

### cloudfoundry
* accepts `--v3` in order to use the `v3-push` command

### codedeploy
* accepts `--file_exist_behavior` in order to specify how to handle files that already exist in a deployment target location

### elasticbeanstalk
* accepts `--label` and `--description` in order to define these attributes
* removes non-printable unicode chars from the version description
* accepts `--debug` in order to list files added to the zip archive
* honors `.ebignore` in order to exclude files from being added to the zip file

### engineyard
* uses `ey-core` as CLI tooling

### firebase
* accepts `--only` in order to restrict the resources to deploy
* accpets `--force` in order to delete functions missing from the current working directory
* adds `node_modules/.bin` to the `PATH` in case users have `firebase` in that directory

### gae
* accepts multiple values on on `--config`

### hackage
* accepts `--publish` in order to publish a package

### lambda
* accepts `--layers` to deploy function layers
* does not require a role and handler name when functions are only being updated
* uses the correct handler name separators for dotnet, go, and java runtimes

### npm
* accepts `--registry` in order to specify the target registry
* accepts `--src` in order to specify a directory or tarball to publish
* accepts `auth` as an `--auth_method` in order to force writing the token to `_auth` in `~/.npmrc`

### pages
* accepts a `--deploy_keys` as an alternative to the GitHub token
* accepts a commit message on `--commit_message`. This message can interpolate variables, such as $TRAVIS_BUILD_NUMBER.
* checks if the target branch already exists and preserves git history by default. `--no-keep_history` can be passed in order to erase history on the target branch.
* includes symbolic links

### pypi
* accepts `--no-remove_build_dir` in order to skip removing the build dir (./dist)
* runs `twine check dist/*` by default, and accepts `--no-twine_check` for opting out

### releases
* accepts a path to a file containing release notes on `--release_notes_file`
* uses `--release_notes` for passing the release notes content, `--body` is still accepted as a deprecated alias

### s3
* accepts `--no-overwrite` in order to not overwrite existing files
* prints out dots instead of filenames by default, and accepts `--verbose` for printing out all filenames uploaded
* uses `application/octet-stream` as a default content type if a content type cannot be determined
