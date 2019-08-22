# Changelog

## dpl v2.0.0-alpha.1 (eta 2019-08-28)

* dpl now defaults not not cleaning the git working directory. users who need to clean up their git working directory need to opt in using `--cleanup`
* dpl now supports a maturity model using dev, alpha, beta, stable
* dpl now uses Ruby's `DidYouMean` in order to suggest provider names if the given name is not valid
* dpl now uses `~/.dpl` rather than `./.dpl` as a directory to store assets, and removes `~/.dpl` before the process terminates
* bintray now lists files in the downloads list if specified in the descriptor file
* chef-supermarket now reads the cookbook name a given metadata.json or metadata.rb file if not given as `--name`
* chef-supermarket now uses `--name` and `--category`, `--cookbook_name` and `--cookbook_category` are still accepted as deprecated aliases
* cloudfoundry now accepts `--v3` in order to use the `v3-push` command
* codedeploy now accepts `--file_exist_behavior` in order to specify how to handle files that already exist in a deployment target location
* codedeploy, elasticbeanstalk, lambda, opsworks, and s3 now use the AWS SDK v3
* elasticbeanstalk now accepts `--label` and `--description` in order to define these attributes
* elasticbeanstalk now removes non-printable unicode chars from the version description
* elasticsearch now accepts `--debug` in order to list files added to the zip archive
* elasticsearch now honors `.ebignore` in order to exclude files from being added to the zip file
* engineyard now uses `ey-core`
* firebase now accepts `--only` in order to restrict the resources to deploy
* firebase now accpets `--force` in order to delete functions missing from the current working directory
* firebase now adds `node_modules/.bin` to the `PATH` in case users have `firebase` in that directory
* gae now accepts multiple values on on `--config`
* git-ssh now works with non-standard ssh ports
* hackage now accepts `--publish` in order to publish a package
* lambda now accepts `--layers` to deploy function layers
* lambda now does not require a role and handler name when functions are only being updated
* lambda now uses the correct handler name separators for dotnet, go, and java runtimes
* npm now accepts `--src` in order to specify a directory or tarball to publish
* npm now accepts `auth` as an `--auth_method` in order to force writing the token to `_auth` in `~/.npmrc`
* pages now accepts a `--deploy_keys` as an alternative to the GitHub token
* pages now accepts a commit message on `--commit_message`. This message can interpolate variables, such as $TRAVIS_BUILD_NUMBER.
* pages now checks if the target branch already exists and preserves git history by default. `--no-keep_history` can be passed in order to erase history on the target branch.
* pages now includes symbolic links
* pypi now accepts `--no-remove_build_dir` in order to skip removing the build dir (./dist)
* pypi now runs `twine check dist/*` by default, and accepts `--no-twine_check` for opting out
* releases now accepts a path to a file containing release notes on `--release_notes_file`
* releases now uses `--release_notes` for passing the release notes content, `--body` is still accepted as a deprecated alias
* s3 now accepts `--no-overwrite` in order to not overwrite existing files
* s3 now prints out dots instead of filenames by default, and accepts `--verbose` for printing out all filenames uploaded
* s3 now uses `application/octet-stream` as a default content type if a content type cannot be determined
