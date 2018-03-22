# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.svg?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Gem Version](https://badge.fury.io/rb/dpl.png)](http://badge.fury.io/rb/dpl) [![Coverage Status](https://coveralls.io/repos/travis-ci/dpl/badge.svg?branch=master&service=github)](https://coveralls.io/github/travis-ci/dpl?branch=master)

## Writing and Testing a New Deployment Provider and new functionality

See [CONTRIBUTING.md](.github/CONTRIBUTING.md).

## Supported Providers:
Dpl supports the following providers:

* [Anynines](#anynines)
* [Atlas by HashiCorp](#atlas)
* [AWS CodeDeploy](#aws-codedeploy)
* [AWS Elastic Beanstalk](#elastic-beanstalk)
* [AWS OpsWorks](#opsworks)
* [AWS S3](#s3)
* [Azure Web Apps](#azure-web-apps)
* [Bintray](#bintray)
* [BitBalloon](#bitballoon)
* [Bluemix Cloud Foundry](#bluemix-cloud-foundry)
* [Boxfuse](#boxfuse)
* [Catalyze](#catalyze)
* [Chef Supermarket](#chef-supermarket)
* [Cloud 66](#cloud-66)
* [Cloud Foundry](#cloud-foundry)
* [Deis](#deis)
* [Divshot.io](#divshotio)
* [Engine Yard](#engine-yard)
* [Firebase](#firebase)
* [Github Pages](#github-pages)
* [Github Releases](#github-releases)
* [Google App Engine (experimental)](#google-app-engine)
* [Google Cloud Storage](#google-cloud-storage)
* [Hackage](#hackage)
* [Heroku](#heroku)
* [Lambda](#lambda)
* [Launchpad](#launchpad)
* [Modulus](#modulus)
* [Nodejitsu](#nodejitsu)
* [NPM](#npm)
* [OpenShift](#openshift)
* [packagecloud](#packagecloud)
* [Puppet Forge](#puppet-forge)
* [PyPi](#pypi)
* [Rackspace Cloud Files](#rackspace-cloud-files)
* [RubyGems](#rubygems)
* [Scalingo](#scalingo)
* [Script](#script)
* [Surge.sh](#surgesh)
* [TestFairy](#testfairy)

## Installation:

Dpl is published to rubygems.

* Dpl requires ruby 2.2 and later.
* To install: `gem install dpl`

## Usage:

### Security Warning:

Running dpl in a terminal that saves history is insecure as your password/api key will be saved as plain text by it.

### Global Flags
* `--provider=<provider>` sets the provider you want to deploy to. Every provider has slightly different flags, which are documented in the section about your provider following.
*  Dpl will deploy by default from the latest commit. Use the `--skip_cleanup`  flag to deploy from the current file state. Note that many providers deploy by git and could ignore this option.

### Heroku:

#### Options:
* **api-key**: Heroku API Key
* **strategy**: Deployment strategy for Dpl. Defaults to `api`. The other option is `git`.
* **app**: Heroku app name. Defaults to the name of your git repo.
* **username**: heroku username. Not necessary if api-key is used. Requires git strategy.
* **password**: heroku password. Not necessary if api-key is used. Requires git strategy.

#### API vs Git Deploy:
* API deploy will tar up the current directory (minus the git repo) and send it to Heroku.
* Git deploy will send the contents of the git repo only, so may not contain any local changes.
* The Git strategy allows using *user* and *password* instead of *api-key*.
* When using Git, Heroku might send you an email for every deploy, as it adds a temporary SSH key to your account.

#### Examples:

    dpl --provider=heroku --api-key=`heroku auth:token`
    dpl --provider=heroku --strategy=git --username=<username> --password=<password>  --app=<application>


### Bintray:

#### Options:

* **file**: Path to a descriptor file, containing information for the Bintray upload.
* **user**: Bintray user
* **key**: Bintray API key
* **passphrase**: Optional. In case a passphrase is configured on Bintray and GPG signing is used.
* **dry-run**: Optional. If set to true, skips sending requests to Bintray. Useful for testing your configuration.

#### Descriptor file example:
```groovy
{
	/* Bintray package information.
	   In case the package already exists on Bintray, only the name, repo and subject
	   fields are mandatory. */

	"package": {
		"name": "auto-upload", // Bintray package name
		"repo": "myRepo", // Bintray repository name
		"subject": "myBintrayUser", // Bintray subject (user or organization)
		"desc": "I was pushed completely automatically",
		"website_url": "www.jfrog.com",
 		"issue_tracker_url": "https://github.com/bintray/bintray-client-java/issues",
 		"vcs_url": "https://github.com/bintray/bintray-client-java.git",
		"github_use_tag_release_notes": true,
		"github_release_notes_file": "RELEASE.txt",
 		"licenses": ["MIT"],
 		"labels": ["cool", "awesome", "gorilla"],
 		"public_download_numbers": false,
 		"public_stats": false,
 		"attributes": [{"name": "att1", "values" : ["val1"], "type": "string"},
     				   {"name": "att2", "values" : [1, 2.2, 4], "type": "number"},
     				   {"name": "att5", "values" : ["2014-12-28T19:43:37+0100"], "type": "date"}]
 	},

	/* Package version information.
	   In case the version already exists on Bintray, only the name fields is mandatory. */

	"version": {
		"name": "0.5",
		"desc": "This is a version",
		"released": "2015-01-04",
		"vcs_tag": "0.5",
	 	"attributes": [{"name": "VerAtt1", "values" : ["VerVal1"], "type": "string"},
  					   {"name": "VerAtt2", "values" : [1, 3.2, 5], "type": "number"},
					   {"name": "VerAtt3", "values" : ["2015-01-01T19:43:37+0100"], "type": "date"}],
		"gpgSign": false
	},

	/* Configure the files you would like to upload to Bintray and their upload path.
	You can define one or more groups of patterns.
	Each group contains three patterns:

	includePattern: Pattern in the form of Ruby regular expression, indicating the path of files to be uploaded to Bintray.
	excludePattern: Optional. Pattern in the form of Ruby regular expression, indicating the path of files to be removed from the list of files specified by the includePattern.
	uploadPattern: Upload path on Bintray. The path can contain symbols in the form of $1, $2,... that are replaced with capturing groups defined in the include pattern.

	In the example below, the following files are uploaded,
	1. All gem files located under build/bin/ (including sub directories),
	except for files under a the do-not-deploy directory.
	The files will be uploaded to Bintray under the gems folder.
	2. All files under build/docs. The files will be uploaded to Bintray under the docs folder.

	Note: Regular expressions defined as part of the includePattern property must be wrapped with brackets. */

	"files":
		[
		{"includePattern": "build/bin(.*)*/(.*\.gem)", "excludePattern": ".*/do-not-deploy/.*", "uploadPattern": "gems/$2"},
		{"includePattern": "build/docs/(.*)", "uploadPattern": "docs/$1"}
		],
	"publish": true
}
```

#### Debian Upload

When artifacts are uploaded to a Debian repository using the Automatic index layout, the Debian distribution information is required and must be specified. The information is specified in the descriptor file by the matrixParams as part of the files closure as shown in the following example:
```groovy
    "files":
        [{"includePattern": "build/bin/(.*\.deb)", "uploadPattern": "$1",
		"matrixParams": {
			"deb_distribution": "vivid",
			"deb_component": "main",
			"deb_architecture": "amd64"}
		}
	]
```

#### Examples:
    dpl --provider=bintray --file=<path> --user=<username> --key=<api-key>
    dpl --provider=bintray --file=<path> --user=<username> --key=<api-key> --passphrase=<passphrase>


### Boxfuse

Boxfuse will transform your .jar or .war file of your JVM-based application into a minimal machine image based upon which it will launch EC2 instances on AWS.

#### Options

* **user**: Your Boxfuse user
* **secret**: Your Boxfuse secret
* **configfile**: The Boxfuse configuration file to use (default: boxfuse.conf)
* **payload**: The file to use as a payload for the image
* **app**: The Boxfuse app to deploy (default: auto-detected based on payload file name)
* **version**: The version to assign to the image (default: auto-detected based on payload file name)
* **env**: The Boxfuse environment to deploy to (default: test)

All options can also be configured directly in boxfuse.conf as described in [the documentation](https://boxfuse.com/docs/commandline/#configuration).

#### Environment Variables

For authentication you can also use Travis CI secure environment variable:

* **BOXFUSE_USER**: Your Boxfuse user
* **BOXFUSE_SECRET**: Your Boxfuse secret

#### Examples
    dpl --provider=boxfuse
    dpl --provider=boxfuse --user=<your-boxfuse-user> --secret=<your-boxfuse-secret> --env=<your-boxfuse-environment>
    dpl --provider=boxfuse --configfile=<your-boxfuse-config-file>


### Nodejitsu:

#### Options:

* **username**: Nodejitsu Username
* **api-key**: Nodejitsu API Key

#### Examples:
    dpl --provider=nodejitsu --username=<username> --api-key=<api-key>


### Modulus

#### Options:

* **api-key** Modulus Authentication Token
* **project-name** Modulus Project to Deploy

#### Example:
    dpl --provider=modulus --api-key=<api-key> --project-name=<project-name>


### Engine Yard:

#### Options:

* **api-key**: Engine Yard Api Key
* **username**: Engine Yard username. Not necessary if api-key is used. Requires git strategy.
* **password**: Engine Yard password. Not necessary if api-key is used.
* **app**: Engine Yard Application name. Defaults to git repo's name.
* **environment**: Engine Yard Application Environment. Optional.
* **migrate**: Engine Yard migration commands. Optional.

#### Examples:

    dpl --provider=engineyard --api-key=<api-key>
    dpl --provider=engineyard --username=<username> --password=<password> --environment=staging
    dpl --provider=engineyard --api-key=<api-key> --app=<application> --migrate=`rake db:migrate`

### OpenShift:

#### Options:

* **user**: Openshift Username.
* **password**: Openshift Password.
* **domain**: Openshift Application Domain.
* **app**: Openshift Application. Defaults to git repo's name.

#### Examples:

    dpl --provider=openshift --user=<username> --password=<password> --domain=<domain>
    dpl --provider=openshift --user=<username> --password=<password> --domain=<domain> --app=<app>

### RubyGems:

#### Options:

* **api-key**: Rubygems Api Key.
* **gemspec**: Optional. The name of the `gemspec` file to use to build the gem.
* **gemspec_glob**: Optional. A glob pattern to search for gemspec files when multiple gems are generated in the repository.
This _overrides_ the `gemspec` option.

#### Examples:

    dpl --provider=rubygems --api-key=<api-key>

### PyPI:

#### Options:

* **user**: PyPI Username.
* **password**: PyPI Password.
* **server**: Optional. Only required if you want to release to a different index. Follows the form of 'https://mypackageindex.com/index'. Defaults to 'https://upload.pypi.org/legacy/'.
* **distributions**: Optional. A space-separated list of distributions to be uploaded to PyPI. Defaults to 'sdist'.
* **skip_upload_docs**: Optional. When set to `false`, documentation is uploaded. Defaults to `true`.
  Note that upload.pypi.org does not support document uploading. If you set
  this option to `false`, your deployment fails, unless you specify the server
  that supports this option. See https://github.com/travis-ci/dpl/issues/660
  for details.
* **docs_dir**: Optional. A path to the directory to upload documentation from. Defaults to 'build/docs'
* **skip_existing**: Optional. When set to `true`, the deployment will not fail if a file with the same name already exists on the server. It won't be uploaded and will not overwrite the existing file. Defaults to `false`.

#### Environment variables:

 * **PYPI_USER**: PyPI Username. Used if the `user` option is omitted.
 * **PYPI_PASSWORD**: PyPI Password. Used if the `password` option is omitted.
 * **PYPI_SERVER** Optional. Only required if you want to release to a different index. Used if the `server` option is omitted.
 * **PYPI_DISTRIBUTIONS** Optional. A space-separated list of distributions to be uploaded to PyPI. Used if the `distributions` option is omitted.
 * **PYPI_DOCS_DIR** Optional. A path to the directory to upload documentation from. Used if the `docs_dir` option is omitted.

#### Examples:

    dpl --provider=pypi --user=<username> --password=<password>
    dpl --provider=pypi --user=<username> --password=<password> --server='https://mypackageindex.com/index' --distributions='sdist bdist_wheel'

### NPM:

#### Options:

* **email**: NPM email.
* **api-key**: NPM api key. Can be retrieved from your ~/.npmrc file.

#### Examples:

    dpl --provider=npm --email=<email> --api-key=<api-key>

### S3:

#### Options:

* **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **bucket**: S3 Bucket.
* **region**: S3 Region. Defaults to us-east-1.
* **upload-dir**: S3 directory to upload to. Defaults to root directory.
* **storage-class**: S3 storage class to upload as. Defaults to "STANDARD". Other values are "STANDARD_IA" or "REDUCED_REDUNDANCY". Details can be found [here](https://aws.amazon.com/s3/storage-classes/).
* **server-side-encryption**: When set to `true`, use S3 Server Side Encryption (SSE-AES256). Defaults to `false`.
* **local-dir**: Local directory to upload from. Can be set from a global perspective (~/travis/build) or relative perspective (build) Defaults to project root.
* **detect-encoding**: Set HTTP header `Content-Encoding` for files compressed with `gzip` and `compress` utilities. Defaults to not set.
* **cache_control**: Set HTTP header `Cache-Control` to suggest that the browser cache the file. Defaults to `no-cache`. Valid options are `no-cache`, `no-store`, `max-age=<seconds>`,`s-maxage=<seconds>` `no-transform`, `public`, `private`.
* **expires**: This sets the date and time that the cached object is no longer cacheable. Defaults to not set. The date must be in the format `YYYY-MM-DD HH:MM:SS -ZONE`.
* **acl**: Sets the access control for the uploaded objects. Defaults to `private`. Valid options are `private`, `public_read`, `public_read_write`, `authenticated_read`, `bucket_owner_read`, `bucket_owner_full_control`.
* **dot_match**: When set to `true`, upload files starting a `.`.
* **index_document_suffix**: Set the index document of a S3 website.
* **default_text_charset**: Set the default character set to append to the content-type of text files you are uploading.
* **max_threads**: The number of threads to use for S3 file uploads. Default is 5, and the absolute maximum is 15.

#### File-specific `Cache-Control` and `Expires` headers

It is possible to set file-specific `Cache-Control` and `Expires` headers using `value: file[, file]` format.

#### Environment variables:

 * **AWS_ACCESS_KEY_ID**: AWS Access Key ID. Used if the `access-key-id` option is omitted.
 * **AWS_SECRET_ACCESS_KEY**: AWS Secret Key. Used if the `secret-access-key` option is omitted.

##### Example:

    --cache_control="no-cache: index.html"
    --expires="\"2012-12-21 00:00:00 -0000\": *.css, *.js"

#### Examples:

    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --acl=public_read
    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --detect-encoding --cache_control=max-age=99999 --expires="2012-12-21 00:00:00 -0000"
    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --region=us-west-2 --local-dir=BUILD --upload-dir=BUILDS

### Elastic Beanstalk:

#### Options:

 * **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
 * **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
 * **region**: AWS Region the Elastic Beanstalk app is running in. Defaults to 'us-east-1'. Please be aware that this must match the region of the elastic beanstalk app.
 * **app**: Elastic Beanstalk application name.
 * **env**: Elastic Beanstalk environment name which will be updated.
 * **zip_file**: The zip file that you want to deploy. _**Note:**_ you also need to use the `skip_cleanup` or the zip file you are trying to upload will be removed during cleanup.
 * **bucket_name**: Bucket name to upload app to.
 * **bucket_path**: Location within Bucket to upload app to.
 * **only_create_app_version**: only create the app version, don't actually deploy it.

#### Environment variables:

 * **ELASTIC_BEANSTALK_ENV**: Elastic Beanstalk environment name which will be updated. Is only used if `env` option is omitted.
 * **ELASTIC_BEANSTALK_LABEL**: Label name of the new version.
 * **ELASTIC_BEANSTALK_DESCRIPTION**: Description of the new version. Defaults to the last commit message.

#### Examples:

    dpl --provider=elasticbeanstalk --access-key-id=<access-key-id> --secret-access-key="<secret-access-key>" --app="example-app-name" --env="example-app-environment" --region="us-west-2"

### OpsWorks:

#### Options:

* **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **app-id**: The app ID.
* **instance-ids**: An instance id. (Use this option multiple times to specify multiple instance ids. Default: [])
* **layer-ids**: A layer id. (Use this option multiple times to specify multiple layer ids. Default: [])
* **migrate**: Migrate the database. (Default: false)
* **wait-until-deployed**: Wait until the app is deployed and return the deployment status. (Default: false)
* **update-on-success**: When **wait-until-deployed** and **updated-on-success** are both `true`, application source is updated to the current SHA. Ignored when **wait-until-deployed** is false. (Default: false)
* **custom_json**: Override custom_json options. If using this, default configuration will be overriden. See the code [here](https://github.com/travis-ci/dpl/blob/master/lib/dpl/provider/ops_works.rb#L43). More about `custom_json` [here](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-json.html).

#### Environment variables:

 * **AWS_ACCESS_KEY_ID**: AWS Access Key ID. Used if the `access-key-id` option is omitted.
 * **AWS_SECRET_ACCESS_KEY**: AWS Secret Key. Used if the `secret-access-key` option is omitted.

#### Examples:

    dpl --provider=opsworks --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --app-id=<app-id> --migrate --wait-until-deployed
    dpl --provider=opsworks --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --app-id=<app-id> --layer-ids=<layer-id>

### Anynines:

#### Options:

* **username**: anynines username.
* **password**: anynines password.
* **organization**: anynines target organization.
* **space**: anynines target space

#### Examples:

    dpl --provider=anynines --username=<username> --password=<password> --organization=<organization> --space=<space>

### Atlas:

The Atlas provider uses the [`atlas-upload-cli`](https://github.com/hashicorp/atlas-upload-cli) command. The [Atlas Upload CLI](https://github.com/hashicorp/atlas-upload-cli) is a lightweight command line interface for uploading application code to [Atlas](https://atlas.hashicorp.com/homepage?utm_source=github&utm_medium=travis-ci&utm_campaign=dpl) to kick off Atlas-based deployment processes from Travis CI.

You first need to create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=travis-ci&utm_campaign=dpl), then, generate an [Atlas API token](https://atlas.hashicorp.com/settings/tokens) for Travis CI.

#### Options:

* **token** (Required): Atlas API token.
* **app** (Required): Atlas application name (`<atlas-username>/<app-name>`).
* **exclude**: Glob pattern of files or directories to exclude (this may be specified multiple times).
* **include**: Glob pattern of files/directories to include (this may be specified multiple times, any excludes will override conflicting includes).
* **address**: The address of the Atlas server.
* **vcs**: Use VCS to determine which files to include/exclude.
* **metadata**: Arbitrary key-value (string) metadata to be sent with the upload; may be specified multiple times.
* **debug**: Turn on debug output.
* **version**: Print the version of this application.

#### Examples:

    dpl --provider=atlas --token=ATLAS_TOKEN --app=ATLAS_USERNAME/APP_NAME
    dpl --provider=atlas --token=ATLAS_TOKEN --app=ATLAS_USERNAME/APP_NAME --debug --vcs --version
    dpl --provider=atlas --token=ATLAS_TOKEN --app=ATLAS_USERNAME/APP_NAME --exclude="*.log" --include="build/*" --include="bin/*"
    dpl --provider=atlas --token=ATLAS_TOKEN --app=ATLAS_USERNAME/APP_NAME --metadata="foo=bar" --metadata="bar=baz"

### Azure Web Apps:

#### Options:

* **site**: Web App Name (if your app lives at myapp.azurewebsites.net, the name would be myapp).
* **slot**: Optional. Slot name if your app uses staging deployment. (e.g. if your slot lives at myapp-test.azurewebsites.net, the slot would be myapp-test).
* **username**: Web App Deployment Username.
* **password**: Web App Deployment Password.
* **verbose**: If passed, Azure's deployment output will be printed. Warning: If you provide incorrect credentials, Git will print those in clear text. Correct authentication credentials will remain hidden.

#### Environment variables:

 * **AZURE_WA_SITE** Web App Name. Used if the `site` option is omitted.
 * **AZURE_WA_SLOT** Optional. Slot name if your app uses staging deployment. Used if the `slot` option is omitted.
 * **AZURE_WA_USERNAME**: Web App Deployment Username. Used if the `username` option is omitted.
 * **AZURE_WA_PASSWORD**: Web App Deployment Password. Used if the `password` option is omitted.

#### Examples:

    dpl --provider=AzureWebApps --username=depluser --password=deplp@ss --site=dplsite --slot=dplsite-test --verbose

### Divshot.io:

#### Options:

* **api-key**: Divshot.io API key
* **environment**: Which environment (development, staging, production) to deploy to

#### Examples:

    dpl --provider=divshot --api-key=<api-key> --environment=<environment>

### Cloud Foundry:

#### Options:

* **username**: Cloud Foundry username.
* **password**: Cloud Foundry password.
* **organization**: Cloud Foundry target organization.
* **api**: Cloud Foundry api URL
* **space**: Cloud Foundry target space
* **manifest**: Path to manifest file. Optional.
* **skip_ssl_validation**: Skip ssl validation. Optional.

#### Examples:

    dpl --provider=cloudfoundry --username=<username> --password=<password> --organization=<organization> --api=<api> --space=<space> --skip-ssl-validation

### Rackspace Cloud Files:

#### Options:

* **username**: Rackspace Username.
* **api-key**: Rackspace API Key.
* **region**: Cloud Files Region. The region in which your Cloud Files container exists.
* **container**: Container Name. The container where you would like your files to be uploaded.
* **dot_match**: When set to `true`, upload files starting a `.`.

#### Examples:

    dpl --provider=cloudfiles --username=<username> --api-key=<api-key> --region=<region> --container=<container>

### GitHub Pages:

#### Options:

* **github-token**: GitHub oauth token with `repo` permission.
* **repo**: Repo slug, defaults to current one.
* **target-branch**: Branch to push force to, defaults to gh-pages.
* **keep-history**: Optional, create incremental commit instead of doing push force, defaults to false.
* **allow-empty-commit**: Optional, defaults to false. Enabled if only keep-history is true.
* **committer-from-gh**: Optional, defaults to false. Allows to use token's owner name and email for commit. Overrides `email` and `name` options.
* **verbose**: Optional, be verbose about internal steps, defaults to false.
* **local-dir**: Directory to push to GitHub Pages, defaults to current.
* **fqdn**: Optional, no default, sets a main domain for your website.
* **project-name**: Defaults to fqdn or repo slug, used for metadata.
* **email**: Optional, committer info, defaults to deploy@travis-ci.org.
* **name**: Optional, committer, defaults to Deployment Bot.
* **deployment-file**: Optional, defaults to false, enables creation of deployment-info files

#### Examples:

    dpl --provider=pages --github-token=<api-key> --local-dir=build

### GitHub Releases:

#### Options:

* **api-key**: GitHub oauth token with `public_repo` or`repo` permission.
* **user**: GitHub username. Not necessary if `api-key` is used.
* **password**: GitHub Password. Not necessary if `api-key` is used.
* **repo**: GitHub Repo. Defaults to git repo's name.
* **file**: File to upload to GitHub Release.
* **file_glob**: If files should be interpreted as globs (\* and \*\* wildcards). Defaults to false.
* **overwrite**: If files with the same name should be overwritten. Defaults to false.
* **release-number**: Overide automatic release detection, set a release manually.
* **prerelease**: Identify the release as a prerelease.

Additionally, options can be passed to [Octokit](https://github.com/octokit/octokit.rb) client.
These are documented in https://github.com/octokit/octokit.rb/blob/master/lib/octokit/client/releases.rb.

#### GitHub Two Factor Authentication

For accounts using two factor authentication, you have to use an oauth token as a username and password will not work.

#### Examples:

    dpl --provider=releases --api-key=<api-key> --file=build.tar.gz

### Cloud 66

#### Options:

* **redeployment_hook**: The redeployment hook URL. Available from the Information menu within the Cloud 66 portal.

#### Examples:

    dpl --provider=cloud66 --redeployment_hook=<url>

### Hackage:

#### Options:

* **username**: Hackage username.
* **password**: Hackage password.

#### Examples:

    dpl --provider=hackage --username=<username> --password=<password>

### Deis:

#### Options:

* **controller**: Deis controller e.g. deis.deisapps.com
* **username**: Deis username
* **password**: Deis password
* **app**: Deis app
* **cli_version**: Install a specific deis cli version

#### Examples:

    dpl --provider=deis --controller=deis.deisapps.com --username=travis --password=secret --app=example

### Google Cloud Storage:

#### Options:

* **access-key-id**: GCS Interoperable Access Key ID. Info about Interoperable Access Key from [here](https://developers.google.com/storage/docs/migrating).
* **secret-access-key**: GCS Interoperable Access Secret.
* **bucket**: GCS Bucket.
* **upload-dir**: GCS directory to upload to. Defaults to root directory.
* **local-dir**: Local directory to upload from. Can be set from a global perspective (~/travis/build) or relative perspective (build) Defaults to project root.
* **dot_match**: When set to `true`, upload files starting a `.`.
* **detect-encoding**: Set HTTP header `Content-Encoding` for files compressed with `gzip` and `compress` utilities. Defaults to not set.
* **cache_control**: Set HTTP header `Cache-Control` to suggest that the browser cache the file. Defaults to not set. Info is [here](https://developers.google.com/storage/docs/reference-headers#cachecontrol)
* **acl**: Sets the access control for the uploaded objects. Defaults to not set. Info is [here](https://developers.google.com/storage/docs/reference-headers#xgoogacl)

#### Examples:

    dpl --provider=gcs --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket>
    dpl --provider=gcs --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --local-dir= BUILD
    dpl --provider=gcs --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --acl=public-read
    dpl --provider=gcs --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --detect-encoding --cache_control=max-age=99999
    dpl --provider=gcs --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --local-dir=BUILD --upload-dir=BUILDS

### BitBalloon:

#### Options:

 * **access_token**: Optional. The access_token which can be found in the `.bitballoon` file after a deployment using the bitballoon CLI. Only required if no `.bitballoon` file is present.
 * **site_id**: Optional. The site_id which can be found in the .bitballoon file after a deployment using the bitballoon CLI. Only required if no `.bitballoon` file is present.
 * **local_dir**: Optional. The sub-directory of the built assets for deployment. Default to current path.

#### Examples:

    dpl --access-token=<access-token> --site-id=3f932c1e-708b-4573-938a-a07d9728c22e
    dpl --access-token=<access-token> --site-id=3f932c1e-708b-4573-938a-a07d9728c22e --local-dir=build

### Puppet Forge:

#### Options:

 * **user**: Required. The user name at Puppet forge.
 * **password**: Required. The Puppet forge password.
 * **url**: Optional. The forge URL to deploy to. Defaults to https://forgeapi.puppetlabs.com/

#### Examples:

    dpl --provider=puppetforge --user=puppetlabs --password=s3cr3t

### packagecloud:

#### Options:

 * **username**: Required. The packagecloud.io username.
 * **token**: Required. The [packagecloud.io api token](https://packagecloud.io/docs/api#api_tokens).
 * **repository**: Required. The repository to push to.
 * **local_dir**: Optional. The sub-directory of the built assets for deployment. Default to current path.
 * **dist**: Required for debian, rpm, and node.js packages. The complete list of supported strings can be found on the [packagecloud.io docs](https://packagecloud.io/docs#os_distro_version). For node.js packages, simply use "node".
 * **force**: Optional. Whether package has to be (re)uploaded / deleted before upload

#### Examples:

    dpl --provider=packagecloud --username=packageuser --token=t0k3n --repository=myrepo
    dpl --provider=packagecloud --username=packageuser --token=t0k3n --repository=myrepo --dist=ubuntu/precise
    dpl --provider=packagecloud --username=packageuser --token=t0k3n --repository=myrepo --local-dir="${TRAVIS_BUILD_DIR}/pkgs" --dist=ubuntu/precise

### Catalyze:

#### Options:

 * **target**: Required. The git remote repository to deploy to.
 * **path**: Optional. If using the skip_cleanup option to deploy from current file state, you can optionally specify the pathspec for the files to deploy. If not specified then all files are deployed.

#### Examples:

    dpl --provider=catalyze --target=ssh://git@git.catalyzeapps.com:2222/app1234.git
    dpl --provider=catalyze --target=ssh://git@git.catalyzeapps.com:2222/app1234.git --skip_cleanup=true
    dpl --provider=catalyze --target=ssh://git@git.catalyzeapps.com:2222/app1234.git --skip_cleanup=true --path=build


#### Setup:

1. Get the deployment target for Catalyze:
  1. Make sure your catalyze environment is [associated](https://resources.catalyze.io/paas/paas-cli-reference/#associate).
  2. Get the git remote by running ```git remote -v``` from within the associated repo.
2. Setup a deployment key to Catalyze for Travis CI:
  1. Install the travis-ci cli.
  2. Get the public SSH key for your travis project and save it to a file by running ```travis pubkey > travis.pub```
  3. Add the key as a deploy key using the catalyze cli within the associated repo. For example:  ```catalyze deploy-keys add travisci ./travis.pub code-1```
3. Setup Catalyze as a known host for Travis CI:
  1. List your known hosts by running ```cat ~/.ssh/known_hosts```
  2. Find and copy the line from known_hosts that includes the git remote found in step #1. It'll look something like "[git.catalyzeapps.com]:2222 ecdsa-sha2-nistp256 BBBB12abZmKlLXNo..."
  3. Update your `before_deploy` step in `.travis.yml` to update the `known_hosts` file:

  ```
  before_deploy:  echo "[git.catalyzeapps.com]:2222 ecdsa-sha2-nistp256 BBBB12abZmKlLXNo..." >> ~/.ssh/known_hosts
  ```

### Chef Supermarket:

#### Options:

 * **user_id**: Required. The user name at Chef Supermarket.
 * **client_key**: Required. The client API key file name.
 * **cookbook_category**: Required. The cookbook category in Supermarket (see: https://docs.getchef.com/knife_cookbook_site.html#id12 )

#### Examples:

    dpl --provider=chef-supermarket --user-id=chef --client-key=.travis/client.pem --cookbook-category=Others

### Lambda:

#### Options:

 * **access_key_id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
 * **secret_access_key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
 * **region**: AWS Region the Lambda function is running in. Defaults to 'us-east-1'.
 * **function_name**: Required. The name of the Lambda being created / updated.
 * **role**: Required. The ARN of the IAM role to assign to this Lambda function.
 * **handler_name**: Required. The function that Lambda calls to begin execution. For NodeJS, it is exported function for the module.
 * **dot_match**: Optional. When `true`, the zipped archive will include the hidden `.*` files. Defaults to `false`.
 * **module_name**: Optional. The name of the module that exports the handler. Defaults to `index`.
 * **zip**: Optional. Either a path to an existing packaged (zipped) Lambda, a directory to package, or a single file to package. Defaults to `Dir.pwd`.
 * **description**: Optional. The description of the Lambda being created / updated. Defaults to "Deploy build #{context.env['TRAVIS_BUILD_NUMBER']} to AWS Lambda via Travis CI"
 * **timeout**: Optional. The function execution time at which Lambda should terminate the function. Defaults to 3 (seconds).
 * **memory_size**: Optional. The amount of memory in MB to allocate to this Lambda. Defaults to 128.
 * **runtime**: Optional. The Lambda runtime to use. Defaults to `node`.
 * **publish**: If `true`, a [new version](http://docs.aws.amazon.com/lambda/latest/dg/versioning-intro.html#versioning-intro-publish-version) of the Lambda function will be created instead of replacing the code of the existing one.
 * **subnet_ids**: Optional. List of subnet IDs to be added to the function. Needs the `ec2:DescribeSubnets` and `ec2:DescribeVpcs` permission for the user of the access/secret key to work.
 * **security_group_ids**: Optional. List of security group IDs to be added to the function. Needs the `ec2:DescribeSecurityGroups` and `ec2:DescribeVpcs` permission for the user of the access/secret key to work.
 * **dead_letter_arn**: Optional. ARN to an SNS or SQS resource used for the dead letter queue. [More about DLQs here](https://docs.aws.amazon
 .com/lambda/latest/dg/dlq.html).
 * **tracing_mode**: Optional. "Active" or "PassThrough" only. Default is "PassThrough".  Needs the `xray:PutTraceSegments` and `xray:PutTelemetryRecords` on the role for this to work. [More on
 Active Tracing here](https://docs.aws.amazon.com/lambda/latest/dg/lambda-x-ray.html).
 * **environment_variables**: Optional. List of Environment Variables to add to the function, needs to be in the format of `KEY=VALUE`. Can be encrypted for added security.
 * **kms_key_arn**: Optional. KMS key ARN to use to encrypt `environment_variables`.
 * **function_tags**: Optional. List of tags to add to the function, needs to be in the format of `KEY=VALUE`. Can be encrypted for added security.

 For a list of all [permissions for Lambda, please refer to the documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-api-permissions-ref.html).

#### Examples:

Deploy contents of current working directory using default module:
```
    dpl --provider="lambda" \
        --access_key_id="${AWS_ACCESS_KEY}" \
        --secret_access_key="${AWS_SECRET_KEY}" \
        --function_name="test-lambda" \
        --role="${AWS_LAMBDA_ROLE}" \
        --handler_name="handler";
```
Deploy contents of a specific directory using specific module name:
```
    dpl --provider="lambda" \
        --access_key_id="${AWS_ACCESS_KEY}" \
        --secret_access_key="${AWS_SECRET_KEY}" \
        --function_name="test-lambda" \
        --role="${AWS_LAMBDA_ROLE}" \
        --zip="${TRAVIS_BUILD_DIR}/dist"  \
        --module_name="copy" \
        --handler_name="handler";
```

### Launchpad:

#### Options:

 * **slug**: Required. `~user-name/project-name/branch-name`
 * **oauth_token**: Required. Your OAUTH token for Launchpad
 * **oauth_token_secret**: Required. Your OAUTH token secret for Launchpad

#### Example:

Deploy contents of current working directory using default module:
```
    dpl --provider="launchpad" \
        --slug="~user-name/project-name/branch-name" \
        --oauth_token="${LAUNCHPAD_OAUTH_TOKEN}" \
        --oauth_token_secret="${LAUNCHPAD_OAUTH_TOKEN_SECRET}";
```

### TestFairy:

Your Android(apk)/iOS(ipa) file will be uploaded to TestFairy,
and your testers can start testing your app.

#### Options:
* **api-key**: TestFairy API Key (https://app.testfairy.com/settings/) run "travis encrypt --add deploy.api-key" on your repo.
* **app-file**: Path to the app file that will be generated after the build (APK/IPA).
* **symbols-file**: Path to the symbols file.
* **testers-groups**: You can set a tester group to be notified about this build (group1,group1).
* **notify**: If true, an email you a changelog will be sent to your users.
* **auto-update**: If true, all the previous installations of this app will be automatically all upgraded to this version.
* **video-quality**: Video quality settings, "high", "medium" or "low". Default is "high".
* **screenshot-interval**: You can choose "1"\"2"\"10" sec.
* **max-duration**: Maximum session recording length, eg "20m" or "1h". Default is "10m". Maximum "24h".
* **advanced-options**: For example (option1,option2)
* **data-only-wifi**: If true, video and recorded metrics will be sent only when connected to a wifi network.
* **record-on-background**: If true, data will be collected while the app on background.
* **video**: If true, Video recording settings "true", "false". Default is "true".
* **icon-watermark**: Add a small watermark to app icon. Default is "false".
* **metrics**: Comma-separated list of metrics to record. View list on http://docs.testfairy.com/Upload_API.html.

#### Examples:

    dpl --provider=testfairy --api-key=<api-key> --app-file="out/Sample.apk" --keystore-file="out/keystore" --storepass=<storepass> --alias=<alias>

### AWS CodeDeploy:

#### Options:

* **access_key_id**: AWS Access Key.
* **secret_access_key**: AWS Secret Access Key.
* **application**: CodeDeploy Application Name.
* **deployment_group**: CodeDeploy Deployment Group Name.
* **revision_type**: CodeDeploy Revision Type (S3 or GitHub).
* **commit_id**: Commit ID in case of GitHub.
* **repository**: Repository Name in case of GitHub.
* **bucket**: S3 bucket in case of S3.
* **region**: AWS Availability Zone.
* **wait_until_deployed**: Wait until the app is deployed and return the deployment status (Optional, Default false).

#### Environment variables:

 * **AWS_ACCESS_KEY_ID**: AWS Access Key ID. Used if the `access_key_id` option is omitted.
 * **AWS_SECRET_ACCESS_KEY**: AWS Secret Key. Used if the `secret_access_key` option is omitted.

#### Examples:

    dpl --provider=codedeploy --access_key_id=<aws access key> --secret_access_key=<aws secret access key> --application=<application name> --deployment_group=<deployment group> --revision_type=<s3/github> --bucket=<bucket name> --commit_id=<commit ID> --repository=<repo name> --region=<AWS availability zone> --wait_until_deployed=<true>

### Scalingo:

#### Options:
* **api_key**: scalingo API Key. Not necessary if username and password are used.
* **username**: scalingo username. Not necessary if api_key is used.
* **password**: scalingo password. Not necessary if api_key is used.
* **remote**: Remote url or git remote name of your git repository. By default remote name is "scalingo".
* **branch**: Branch of your git repository. By default branch name is "master".
* **app**: Only necessary if your repository does not contain the appropriate remote. Specifying the app will add a remote to your local repository: `git remote add <remote> git@scalingo.com:<app>.git`

#### Use:

You can connect to Scalingo using your username/password or your api key.
It needs [Scalingo CLI](http://cli.scalingo.com/) which will be [downloaded here](http://cli.scalingo.com/).
Then, it will push your project to Scalingo and deploy it automatically.

Note: You only need to connect once to Scalingo CLI, credentials are stored locally.

#### Examples:

    dpl --provider=scalingo --api_key="aaAAbbBB0011223344"
    dpl --provider=scalingo --username=<username> --password=<password>

    dpl --provider=scalingo --api_key="aaAAbbBB0011223344" --remote="scalingo-staging"
    dpl --provider=scalingo --api_key="aaAAbbBB0011223344" --remote="scalingo-staging" --branch="master"

    dpl --provider=scalingo

### Script:

An elementary provider that executes a single command.

Deployment will be marked a failure if the script exits with nonzero status.

#### Option:

* **script**: script to execute.

#### Example:

    dpl --provider=script --script=./script/deploy.sh

### Google App Engine:

Deploys to Google App Engine and Google App Engine Managed VMs via the Google Cloud SDK and
it's [`gcloud` tool](https://cloud.google.com/sdk/gcloud/) using a [Service Account](https://developers.google.com/console/help/new/#serviceaccounts).
In order to use this provider, please make sure you have the [App Engine Admin API](https://developers.google.com/apis-explorer/#p/appengine/v1beta4/) enabled [in the Google Developers Console](https://console.developers.google.com/project/_/apiui/apiview/appengine/overview).

#### Options:

* **project**: [Project ID](https://developers.google.com/console/help/new/#projectnumber) used to identify the project on Google Cloud.
* **keyfile**: Path to the JSON file containing your [Service Account](https://developers.google.com/console/help/new/#serviceaccounts) credentials in [JSON Web Token](https://tools.ietf.org/html/rfc7519) format. To be obtained via the [Google Developers Console](https://console.developers.google.com/project/_/apiui/credential). Defaults to `"service-account.json"`. Note that this file should be handled with care as it contains authorization keys.
* **config**: Path to your module configuration file. Defaults to `"app.yaml"`. This file is runtime dependent ([Go](https://cloud.google.com/appengine/docs/go/config/appconfig), [Java](https://cloud.google.com/appengine/docs/java/configyaml/appconfig_yaml), [PHP](https://developers.google.com/console/help/new/#projectnumber), [Python](https://cloud.google.com/appengine/docs/python/config/appconfig))
* **version**: The version of the app that will be created or replaced by this deployment. If you do not specify a version, one will be generated for you. See [`gcloud preview app deploy`](https://cloud.google.com/sdk/gcloud/reference/preview/app/deploy)
* **no_promote**: Flag to not promote the deployed version. See [`gcloud preview app deploy`](https://cloud.google.com/sdk/gcloud/reference/preview/app/deploy)
* **verbosity**: Let's you adjust the verbosity when invoking `"gcloud"`. Defaults to `"warning"`. See [`gcloud`](https://cloud.google.com/sdk/gcloud/reference/).
* **no_stop_previous_version**: Flag to prevent your deployment from stopping the previously promoted version. This is from the future, so might not work (yet). See [`gcloud preview app deploy`](https://cloud.google.com/sdk/gcloud/reference/preview/app/deploy)

#### Environment variables:

 * **GOOGLECLOUDPROJECT** or **CLOUDSDK_CORE_PROJECT**: Can be used instead of the `project` option.
 * **GOOGLECLOUDKEYFILE**: Can be used instead of the `keyfile` option.

#### Example:

    dpl --provider=gae --project=example --no_promote=true

### Firebase:

#### Options:

* **token**: Your Firebase CI access token (generate with `firebase login:ci`)
* **project**: Deploy to a different Firebase project than specified in your `firebase.json` (e.g. `myapp-staging`)
* **message**: Optional. The message describing this deploy.

#### Examples:

    dpl --provider=firebase --token=<token> --project=<project> --message=<message>



### Surge.sh

#### Options:

* **project** Path to project folder relative to repo root. Defaults to repo root if not set.
* **domain** Domain to publish to. Can be omitted if domain is set in the `CNAME` file in the project folder.


#### Environment variables:

* **SURGE_LOGIN**: Set it to the email address you use with Surge
* **SURGE_TOKEN**: Set it to your login token (get it by doing a `surge token`)

#### Example:
    dpl --provider=surge --project=<project-path> --domain=<domain-name>

### Bluemix Cloud Foundry:

#### Options:

* **username**: Bluemix username.
* **password**: Bluemix password.
* **organization**: Bluemix target organization.
* **space**: Bluemix target space
* **region**: Bluemix region [ng, eu-gb, eu-de, au-syd]. Optional, default US region (ng).
* **api**: Bluemix api URL. Optional for Bluemix dedicated. Explicit **api** setting precedence over **region** setting.
* **manifest**: Path to manifest file. Optional.
* **skip_ssl_validation**: Skip ssl validation. Optional.

#### Examples:

    dpl --provider=bluemixcloudfoundry --username=<username> --password=<password> --organization=<organization> --region=<region> --space=<space> --skip-ssl-validation

## `dpl` and `sudo`

`dpl` installs deployment provider code as the user invoking
`dpl` at run time, if it is not available.
This causes [a problem](https://github.com/travis-ci/dpl/issues/769)
if you invoke `dpl` via `dpl`, where the process instaling the
provider code may not have sufficient permissions.

In this case, you can install the provider gem (of the same version as
`dpl`) with `sudo` beforehand to work around this issue.
