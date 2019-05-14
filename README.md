# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.svg?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Gem Version](https://badge.fury.io/rb/dpl.png)](http://badge.fury.io/rb/dpl) [![Coverage Status](https://coveralls.io/repos/travis-ci/dpl/badge.svg?branch=master&service=github)](https://coveralls.io/github/travis-ci/dpl?branch=master)

## Writing and Testing a New Deployment Provider and new functionality

See [CONTRIBUTING.md](.github/CONTRIBUTING.md).

## Supported Providers

Dpl supports the following providers:

<<<<<<< HEAD
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
* [cargo](#cargo)
* [Catalyze](#catalyze)
* [Chef Supermarket](#chef-supermarket)
* [Cloud 66](#cloud-66)
* [Cloud Foundry](#cloud-foundry)
* [Deis](#deis)
* [Engine Yard](#engine-yard)
* [Firebase](#firebase)
* [Github Pages](#github-pages)
* [Github Releases](#github-releases)
* [Google App Engine (experimental)](#google-app-engine)
* [Google Cloud Storage](#google-cloud-storage)
* [Hackage](#hackage)
* [Hephy](#hephy)
* [Heroku](#heroku)
* [Lambda](#lambda)
* [Launchpad](#launchpad)
* [Nodejitsu](#nodejitsu)
* [npm](#npm)
* [OpenShift](#openshift)
* [packagecloud](#packagecloud)
* [Puppet Forge](#puppet-forge)
* [PyPi](#pypi)
* [Rackspace Cloud Files](#rackspace-cloud-files)
* [RubyGems](#rubygems)
* [Scalingo](#scalingo)
* [Script](#script)
* [Snap](#snap)
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
||||||| merged common ancestors
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
* [cargo](#cargo)
* [Catalyze](#catalyze)
* [Chef Supermarket](#chef-supermarket)
* [Cloud 66](#cloud-66)
* [Cloud Foundry](#cloud-foundry)
* [Deis](#deis)
* [Engine Yard](#engine-yard)
* [Firebase](#firebase)
* [Github Pages](#github-pages)
* [Github Releases](#github-releases)
* [Google App Engine (experimental)](#google-app-engine)
* [Google Cloud Storage](#google-cloud-storage)
* [Hackage](#hackage)
* [Hephy](#hephy)
* [Heroku](#heroku)
* [Lambda](#lambda)
* [Launchpad](#launchpad)
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
* [Snap](#snap)
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
=======
  * [Anynines](#azure_web_apps)
||||||| merged common ancestors
  * [Anynines](#azure_web_apps)
=======
>>>>>>> make full_name a dsl method
  * [Anynines](#anynines)
  * [Atlas](#atlas)
  * [AWS Code Deploy](#code_deploy)
  * [AWS Elastic Beanstalk](#elastic_beanstalk)
  * [AWS Lambda](#lambda)
  * [AWS OpsWorks](#ops_works)
  * [AWS S3](#s3)
  * [Azure Web Apps](#azure_web_apps)
  * [BitBalloon](#bit_balloon)
  * [Bluemix Cloud Foundry](#bluemix_cloud_foundry)
  * [Boxfuse](#boxfuse)
  * [Cargo](#cargo)
  * [Catalyze](#catalyze)
  * [Chef Supermarket](#chef_supermarket)
  * [Cloud Files](#cloud_files)
  * [Cloud Foundry](#cloud_foundry)
  * [Cloud66](#cloud66)
  * [Deis](#deis)
  * [EngineYard](#engine_yard)
  * [Firebase](#firebase)
  * [GitHub Pages](#pages)
  * [GitHub Releases](#releases)
  * [Google App Engine](#gae)
  * [Google Cloud Store](#gcs)
  * [Hackage](#hackage)
  * [Hephy](#hephy)
  * [Heroku API](#heroku:api)
  * [Heroku Git](#heroku:git)
  * [Launchpad](#launchpad)
  * [NPM](#npm)
  * [Open Shift](#open_shift)
  * [Packagecloud](#packagecloud)
  * [Puppet Forge](#puppet_forge)
  * [PyPI](#pypi)
  * [Rubygems](#rubygems)
  * [Scalingo](#scalingo)
  * [Script](#script)
  * [Snap](#snap)
  * [Surge](#surge)
  * [Testfairy](#testfairy)
  * [Transifex](#transifex)

## Requirements

Dpl requires Ruby 2.2 or later.

## Installation

Installation:

```
gem install dpl
```

## Usage

### Security Warning

Running `dpl` in a terminal that saves history is potentially insecure as credentials may be saved as plain text in the history file, depending on the provider used.

### Note

Dpl will deploy by default from the latest commit. Use the `--skip_cleanup` option to deploy from the current file system state, which may include artifacts left by your build process. Note that providers that deploy via git may ignore this option.

## Dpl and sudo

Dpl may install additional deployment provider specific gem dependencies at runtime. This can cause [a problem](https://github.com/travis-ci/dpl/issues/769) if `sudo dpl` is used, where the process installing the provider code may not have sufficient permissions. In this case, you can install the provider gem (of the same version as `dpl`) with `sudo` beforehand to work around this issue (e.g. `sudo gem install dpl dpl-s3`).

## Providers

### Anynines

```
Usage: readme anynines [options]

Options:

  --username USER         anynines username (type: string, required: true)
  --password PASS         anynines password (type: string, required: true)
  --organization ORG      anynines target organization (type: string, required: true)
  --space SPACE           anynines target space (type: string, required: true)
  --app_name APP          Application name (type: string)
  --manifest FILE         Path to the manifest (type: string)

Common Options:

  --app NAME              type: string, default: repo name
  --key_name NAME         type: string, default: machine name
  --run CMD               type: array (string, can be given multiple times)
  --skip-cleanup          type: flag
  --help                  Get help on this command (type: flag)

Summary:

  Anynines deployment provider

Description:
>>>>>>> auto generate readme

  tbd

```

### Atlas

```
Usage: readme atlas [options]

Options:

  --app APP            The Atlas application to upload to (type: string, required: true)
  --token TOKEN        The Atlas API token (type: string, required: true)
  --path PATH          Files or directories to upload (type: array (string, can be given multiple
                       times), default: ["."])
  --address ADDR       The address of the Atlas server (type: string)
  --include GLOB       Glob pattern of files or directories to include (type: array (string, can be
                       given multiple times))
  --exclude GLOB       Glob pattern of files or directories to exclude (type: array (string, can be
                       given multiple times))
  --metadata DATA      Arbitrary key=value (string) metadata to be sent with the upload (type: array
                       (string, can be given multiple times))
  --vcs                Get lists of files to exclude and include from a VCS (Git, Mercurial or SVN)
                       (type: flag)
  --args ARGS          Args to pass to the atlas-upload CLI (type: string)
  --debug              Turn on debug output (type: flag)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Atlas deployment provider

Description:

  tbd

```

### AWS Code Deploy

```
Usage: readme code_deploy [options]

Options:

  --access_key_id ID            AWS access key (type: string, required: true)
  --secret_access_key KEY       AWS secret access key (type: string, required: true)
  --application NAME            CodeDeploy application name (type: string, required: true)
  --deployment_group GROUP      CodeDeploy deployment group name (type: string)
  --revision_type TYPE          CodeDeploy revision type (type: string, known values: s3, or, github, downcase:
                                true)
  --commit_id SHA               Commit ID in case of GitHub (type: string)
  --repository NAME             Repository name in case of GitHub (type: string)
  --bucket NAME                 S3 bucket in case of S3 (type: string)
  --region REGION               AWS availability zone (type: string, default: us-east-1)
  --wait_until_deployed         Wait until the deployment has finished (type: flag)
  --bundle_type TYPE            type: string
  --endpoint ENDPOINT           type: string
  --key KEY                     type: string
  --description DESCR           type: string

Common Options:

  --app NAME                    type: string, default: repo name
  --key_name NAME               type: string, default: machine name
  --run CMD                     type: array (string, can be given multiple times)
  --skip-cleanup                type: flag
  --help                        Get help on this command (type: flag)

Summary:

  AWS Code Deploy deployment provider

Description:

  tbd

```

### AWS Elastic Beanstalk

```
Usage: readme elastic_beanstalk [options]

Options:

  --access_key_id ID             AWS Access Key ID (type: string, required: true)
  --secret_access_key KEY        AWS Secret Key (type: string, required: true)
  --region REGION                AWS Region the Elastic Beanstalk app is running in (type: string, default:
                                 us-east-1)
  --app NAME                     Elastic Beanstalk application name (type: string)
  --env NAME                     Elastic Beanstalk environment name which will be updated (type: string,
                                 required: true)
  --bucket_name NAME             Bucket name to upload app to (type: string, required: true)
  --bucket_path PATH             Location within Bucket to upload app to (type: string)
  --zip_file PATH                The zip file that you want to deploy (type: string, requires: skip_cleanup)
  --only_create_app_version      Only create the app version, do not actually deploy it (type: flag)
  --wait_until_deployed          Wait until the deployment has finished (type: flag)
  --label LABEL                  type: string
  --description DESC             type: string

Common Options:

  --app NAME                     type: string, default: repo name
  --key_name NAME                type: string, default: machine name
  --run CMD                      type: array (string, can be given multiple times)
  --skip-cleanup                 type: flag
  --help                         Get help on this command (type: flag)

Summary:

  AWS Elastic Beanstalk deployment provider

Description:

  tbd

```

### AWS Lambda

```
Usage: readme lambda [options]

Options:

  --access_key_id ID                AWS access key id (type: string, required: true)
  --secret_access_key KEY           AWS secret key (type: string, required: true)
  --region REGION                   AWS region the Lambda function is running in (type: string, default: us-east-1)
  --function_name FUNC              Name of the Lambda being created or updated (type: string, required: true)
  --role ROLE                       ARN of the IAM role to assign to the Lambda function (type: string, required:
                                    true)
  --handler_name NAME               Function the Lambda calls to begin executio. (type: string, required: true)
  --dot_match                       Include hidden .* files to the zipped archive (type: flag)
  --module_name NAME                Name of the module that exports the handler (type: string, default: index)
  --zip PATH                        Path to a packaged Lambda, a directory to package, or a single file to package
                                    (type: string, default: .)
  --description DESCR               Description of the Lambda being created or updated (type: string)
  --timeout SECS                    Function execution time (in seconds) at which Lambda should terminate the
                                    function (type: string, default: 3)
  --memory_size MB                  Amount of memory in MB to allocate to this Lambda (type: string, default: 128)
  --runtime NAME                    Lambda runtime to use (type: string, default: node)
  --publish                         Create a new version of the code instead of replacing the existing one. (type:
                                    flag)
  --subnet_ids IDS                  List of subnet IDs to be added to the function. Needs the ec2:DescribeSubnets
                                    and ec2:DescribeVpcs permission for the user of the access/secret key to work.
                                    (type: array (string, can be given multiple times))
  --security_group_ids IDS          List of security group IDs to be added to the function. Needs the
                                    ec2:DescribeSecurityGroups and ec2:DescribeVpcs permission for the user of the
                                    access/secret key to work. (type: array (string, can be given multiple times))
  --dead_letter_arn ARN             ARN to an SNS or SQS resource used for the dead letter queue. (type: string)
  --tracing_mode MODE               "Active" or "PassThrough" only. Needs the xray:PutTraceSegments and
                                    xray:PutTelemetryRecords on the role for this to work. (type: string, default:
                                    PassThrough)
  --environment_variables VARS      List of Environment Variables to add to the function, needs to be in the format
                                    of KEY=VALUE. Can be encrypted for added security. (type: array (string, can be
                                    given multiple times))
  --kms_key_arn ARN                 KMS key ARN to use to encrypt environment_variables. (type: string)
  --function_tags TAGS              List of tags to add to the function, needs to be in the format of KEY=VALUE. Can
                                    be encrypted for added security. (type: array (string, can be given multiple
                                    times))

Common Options:

  --app NAME                        type: string, default: repo name
  --key_name NAME                   type: string, default: machine name
  --run CMD                         type: array (string, can be given multiple times)
  --skip-cleanup                    type: flag
  --help                            Get help on this command (type: flag)

Summary:

  AWS Lambda deployment provider

Description:

  tbd

```

### AWS OpsWorks

```
Usage: readme ops_works [options]

Options:

  --access_key_id ID           AWS access key id (type: string, required: true)
  --secret_access_key KEY      AWS secret key (type: string, required: true)
  --app_id APP                 The app id (type: string, required: true)
  --region REGION              AWS region (type: string, default: us-east-1)
  --instance_ids ID            An instance id (type: array (string, can be given multiple times))
  --layer_ids ID               A layer id (type: array (string, can be given multiple times))
  --migrate                    Migrate the database. (type: flag)
  --wait_until_deployed        Wait until the app is deployed and return the deployment status. (type: flag)
  --update_on_success          When wait-until-deployed and updated-on-success are both not given, application
                               source is updated to the current SHA. Ignored when wait-until-deployed is not
                               given. (type: flag)
  --custom_json JSON           Custom json options override (overwrites default configuration) (type: string)

Common Options:

  --app NAME                   type: string, default: repo name
  --key_name NAME              type: string, default: machine name
  --run CMD                    type: array (string, can be given multiple times)
  --skip-cleanup               type: flag
  --help                       Get help on this command (type: flag)

Summary:

  AWS OpsWorks deployment provider

Description:

  tbd

```

### AWS S3

```
Usage: readme s3 [options]

Options:

  --access_key_id ID                  AWS access key id (type: string, required: true)
  --secret_access_key KEY             AWS secret key (type: string, required: true)
  --bucket BUCKET                     S3 bucket (type: string, required: true)
  --region REGION                     S3 region (type: string, default: us-east-1)
  --endpoint URL                      S3 endpoint (type: string)
  --upload_dir DIR                    S3 directory to upload to (type: string)
  --storage_class CLASS               S3 storage class to upload as (type: string, default: STANDARD, known values:
                                      STANDARD, STANDARD_IA, REDUCED_REDUNDANCY)
  --server_side_encryption            Use S3 Server Side Encryption (SSE-AES256) (type: flag)
  --local_dir DIR                     Local directory to upload from (type: string, default: ., e.g.: ~/travis/build
                                      (absolute path) or ./build (relative path))
  --detect_encoding                   HTTP header Content-Encoding for files compressed with gzip and compress
                                      utilities (type: flag)
  --cache_control STR                 HTTP header Cache-Control to suggest that the browser cache the file (type:
                                      string, default: no-cache, known values: no-cache, no-store, /max-age=\d+/,
                                      /s-maxage=\d+/, no-transform, public, private)
  --expires DATE                      Date and time that the cached object expires (type: string, format:
                                      /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .+$/)
  --acl ACL                           Access control for the uploaded objects (type: string, default: private, known
                                      values: private, public_read, public_read_write, authenticated_read,
                                      bucket_owner_read, bucket_owner_full_control)
  --dot_match                         Upload hidden files starting with a dot (type: flag)
  --index_document_suffix SUFFIX      Index document suffix of a S3 website (type: string)
  --default_text_charset CHARSET      Default character set to append to the content-type of text files (type: string)
  --max_threads NUM                   The number of threads to use for S3 file uploads (type: integer, default: 5,
                                      max: 15)

Common Options:

  --app NAME                          type: string, default: repo name
  --key_name NAME                     type: string, default: machine name
  --run CMD                           type: array (string, can be given multiple times)
  --skip-cleanup                      type: flag
  --help                              Get help on this command (type: flag)

Summary:

  AWS S3 deployment provider

Description:

  tbd

```

### Azure Web Apps

```
Usage: readme azure_web_apps [options]

Options:

  --site SITE          Web App name (e.g. myapp in myapp.azurewebsites.net) (type: string, required:
                       true)
  --username NAME      Web App Deployment Username (type: string, required: true)
  --password PASS      Web App Deployment Password (type: string, required: true)
  --slot SLOT          Slot name (if your app uses staging deployment) (type: string)
  --verbose            Print deployment output from Azure. Warning: If authentication fails, Git prints
                       credentials in clear text. Correct credentials remain hidden. (type: flag)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Azure Web Apps deployment provider

Description:

  tbd

```

### BitBalloon

```
Usage: readme bit_balloon [options]

Options:

  --access_token TOKEN      The access token (type: string, required: true)
  --site_id ID              The side id (type: string, required: true)
  --local_dir DIR           The sub-directory of the built assets for deployment (type: string, default: .)

Common Options:

  --app NAME                type: string, default: repo name
  --key_name NAME           type: string, default: machine name
  --run CMD                 type: array (string, can be given multiple times)
  --skip-cleanup            type: flag
  --help                    Get help on this command (type: flag)

Summary:

  BitBalloon deployment provider

Description:

  BitBallon provides free simple static site hosting.

  This deployment provider helps you deploy to BitBallon easily.

```

### Bluemix Cloud Foundry

```
Usage: readme bluemix_cloud_foundry [options]

Options:

  --username USER            Bluemix username (type: string, required: true)
  --password PASS            Bluemix password (type: string, required: true)
  --organization ORG         Bluemix target organization (type: string, required: true)
  --space SPACE              Bluemix target space (type: string, required: true)
  --region REGION            Bluemix region (type: string, default: ng, known values: ng, eu-gb, eu-de,
                             au-syd)
  --api URL                  Bluemix api URL (type: string)
  --app_name APP             Application name (type: string)
  --manifest FILE            Path to the manifest (type: string)
  --skip_ssl_validation      Skip SSL validation (type: flag)

Common Options:

  --app NAME                 type: string, default: repo name
  --key_name NAME            type: string, default: machine name
  --run CMD                  type: array (string, can be given multiple times)
  --skip-cleanup             type: flag
  --help                     Get help on this command (type: flag)

Summary:

  Bluemix Cloud Foundry deployment provider

Description:

  tbd

```

### Boxfuse

```
Usage: readme boxfuse [options]

Options:

  --user USER             type: string
  --secret SECRET         type: string
  --config_file FILE      type: string, alias: configfile (deprecated, please use config_file)
  --payload PAYLOAD       type: string
  --image IMAGE           type: string
  --env ENV               type: string
  --args ARGS             type: string, alias: extra_args (deprecated, please use args)

Common Options:

  --app NAME              type: string, default: repo name
  --key_name NAME         type: string, default: machine name
  --run CMD               type: array (string, can be given multiple times)
  --skip-cleanup          type: flag
  --help                  Get help on this command (type: flag)

Summary:

  Boxfuse deployment provider

Description:

  BitBallon does something.

```

### Cargo

```
Usage: readme cargo [options]

Options:

  --token TOKEN        Cargo registry API token (type: string, required: true)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Cargo deployment provider

Description:

  tbd

```

### Catalyze

```
Usage: readme catalyze [options]

Options:

  --target TARGET      The git remote repository to deploy to (type: string, required: true)
  --path PATH          Path to files to deploy (type: string, default: .)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Catalyze deployment provider

Description:

  tbd

```

### Chef Supermarket

```
Usage: readme chef_supermarket [options]

Options:

  --user_id ID                 Chef Supermarket user name (type: string, required: true)
  --client_key KEY             Client API key file name (type: string, required: true)
  --cookbook_name NAME         Cookbook name (type: string, default: repo name)
  --cookbook_category CAT      Cookbook category in Supermarket (type: string, required: true, see:
                               https://docs.getchef.com/knife_cookbook_site.html#id12)

Common Options:

  --app NAME                   type: string, default: repo name
  --key_name NAME              type: string, default: machine name
  --run CMD                    type: array (string, can be given multiple times)
  --skip-cleanup               type: flag
  --help                       Get help on this command (type: flag)

Summary:

  Chef Supermarket deployment provider

Description:

  tbd

```

### Cloud Files

```
Usage: readme cloud_files [options]

Options:

  --username USER       Rackspace username (type: string, required: true)
  --api_key KEY         Rackspace API key (type: string, required: true)
  --region REGION       Cloudfiles region (type: string, required: true, known values: ord, dfw, syd,
                        iad, hkg)
  --container NAME      Name of the container that files will be uploaded to (type: string, required:
                        true)
  --glob GLOB           Paths to upload (type: string, default: **/*)
  --dot_match           Upload hidden files starting a dot (type: flag)

Common Options:

  --app NAME            type: string, default: repo name
  --key_name NAME       type: string, default: machine name
  --run CMD             type: array (string, can be given multiple times)
  --skip-cleanup        type: flag
  --help                Get help on this command (type: flag)

Summary:

  Cloud Files deployment provider

Description:

  tbd

```

### Cloud Foundry

```
Usage: readme cloud_foundry [options]

Options:

  --username USER            Cloud Foundry username (type: string, required: true)
  --password PASS            Cloud Foundry password (type: string, required: true)
  --organization ORG         Cloud Foundry target organization (type: string, required: true)
  --space SPACE              Cloud Foundry target space (type: string, required: true)
  --api URL                  Cloud Foundry api URL (type: string, required: true)
  --app_name APP             Application name (type: string)
  --manifest FILE            Path to the manifest (type: string)
  --skip_ssl_validation      Skip SSL validation (type: flag)

### npm:

Common Options:

  --app NAME                 type: string, default: repo name
  --key_name NAME            type: string, default: machine name
  --run CMD                  type: array (string, can be given multiple times)
  --skip-cleanup             type: flag
  --help                     Get help on this command (type: flag)

Summary:

  Cloud Foundry deployment provider

    dpl --provider=npm --email=<email> --api-key=<token>
    dpl --provider=npm --email=<email> --api-key=<api-key>

Description:

  tbd

```

### Cloud66

```
Usage: readme cloud66 [options]

Options:

  --redeployment_hook URL      The redeployment hook URL (type: string, required: true)

Common Options:

  --app NAME                   type: string, default: repo name
  --key_name NAME              type: string, default: machine name
  --run CMD                    type: array (string, can be given multiple times)
  --skip-cleanup               type: flag
  --help                       Get help on this command (type: flag)

Summary:

  Cloud66 deployment provider

Description:

  tbd

```

### Deis

```
Usage: readme deis [options]

Options:

  --controller NAME      Deis controller (type: string, required: true, e.g.: deis.deisapps.com)
  --username USER        Deis username (type: string, required: true)
  --password PASS        Deis password (type: string, required: true)
  --app APP              Deis app (type: string, required: true)
  --cli_version VER      Install a specific deis cli version (type: string, default: stable)
  --verbose              Verbose log output (type: flag)

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  Deis deployment provider

Description:

  tbd

```

### EngineYard

```
Usage: readme engine_yard [options]

Options:

  Either api_key, or email and password are required.

  --api_key KEY          Engine Yard API key (type: string)
  --email EMAIL          Engine Yard account email (type: string)
  --password PASS        Engine Yard password (type: string)
  --app APP              Engine Yard application name (type: string, default: repo name)
  --environment ENV      Engine Yard application environment (type: string)
  --migrate CMD          Engine Yard migration commands (type: string)
  --account NAME         type: string

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  EngineYard deployment provider

Description:

  tbd

```

### Firebase

```
Usage: readme firebase [options]

Options:

  --token TOKEN        Firebase CI access token (generate with firebase login:ci) (type: string,
                       required: true)
  --project NAME       Firebase project to deploy to (defaults to the one specified in your
                       firebase.json) (type: string)
  --message MSG        Message describing this deployment. (type: string)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Firebase deployment provider

Description:

  tbd

```

### GitHub Pages

```
Usage: readme pages [options]

Options:

  --github_token TOKEN        GitHub oauth token with repo permission (type: string, required: true)
  --repo SLUG                 Repo slug, defaults to current one (type: string, default: repo slug)
  --target_branch BRANCH      Branch to push force to (type: string, default: gh-pages)
  --keep_history              Create incremental commit instead of doing push force, defaults to false (type:
                              flag)
  --allow_empty_commit        Allow an empty commit to be created (type: flag, requires: keep_history)
  --committer_from-gh         Use the token's owner name and email for commit. Overrides the email and name
                              options (type: flag)
  --verbose                   Be verbose about the deploy process (type: flag)
  --local_dir DIR             Directory to push to GitHub Pages, defaults to current (type: string, default:
                              .)
  --fqdn FQDN                 Writes your website's domain name to the CNAME file (type: string)
  --project_name NAME         Used in the commit message only (defaults to fqdn or the current repo slug)
                              (type: string)
  --email EMAIL               Committer email (type: string, default: deploy@travis-ci.org)
  --name NAME                 Committer name (type: string, default: Deploy Bot)
  --deployment-file           Enable creation of a deployment-info file (type: flag)
  --github_url URL            type: string, default: github.com

Common Options:

  --app NAME                  type: string, default: repo name
  --key_name NAME             type: string, default: machine name
  --run CMD                   type: array (string, can be given multiple times)
  --skip-cleanup              type: flag
  --help                      Get help on this command (type: flag)

Summary:

  GitHub Pages deployment provider

Description:

  tbd

```

### GitHub Releases

```
Usage: readme releases [options]

Options:

  Either api_key, or user and password are required.

  --api_key TOKEN             GitHub oauth token (needs public_repo or repo permission) (type: string)
  --username LOGIN            GitHub login name (type: string, alias: user)
  --password PASS             GitHub password (type: string)
  --repo SLUG                 GitHub repo slug (type: string, default: repo slug)
  --file FILE                 File to release to GitHub (type: array (string, can be given multiple times),
                              required: true)
  --file_glob                 Interpret files as globs (type: flag)
  --overwrite                 Overwrite files with the same name (type: flag)
  --prerelease                Identify the release as a prerelease (type: flag)
  --release_number NUM        Release number (overide automatic release detection) (type: string)
  --draft                     Identify the release as a draft (type: flag)
  --tag_name TAG              Git tag from which to create the release (type: string)
  --target_commitish STR      Commitish value that determines where the Git tag is created from (type: string)
  --name NAME                 Name for the release (type: string)
  --body BODY                 Content for the release notes (type: string)

Common Options:

  --app NAME                  type: string, default: repo name
  --key_name NAME             type: string, default: machine name
  --run CMD                   type: array (string, can be given multiple times)
  --skip-cleanup              type: flag
  --help                      Get help on this command (type: flag)

Summary:

  GitHub Releases deployment provider

Description:

  tbd

```

### Google App Engine

```
Usage: readme gae [options]

Options:

  --project ID                    Project ID used to identify the project on Google Cloud (type: string, required:
                                  true)
  --keyfile FILE                  Path to the JSON file containing your Service Account credentials in JSON Web
                                  Token format. To be obtained via the Google Developers Console. Should be
                                  handled with care as it contains authorization keys. (type: string, default:
                                  service-account.json)
  --config FILE                   Path to your module configuration file (type: string, default: app.yaml)
  --version VER                   The version of the app that will be created or replaced by this deployment. If
                                  you do not specify a version, one will be generated for you (type: string)
  --verbosity LEVEL               Adjust the log verbosity (type: string, default: warning)
  --no_promote                    Do not promote the deployed version (type: flag)
  --no_stop_previous_version      Prevent your deployment from stopping the previously promoted version. This is
                                  from the future, so might not work (yet). (type: flag)

Common Options:

  --app NAME                      type: string, default: repo name
  --key_name NAME                 type: string, default: machine name
  --run CMD                       type: array (string, can be given multiple times)
  --skip-cleanup                  type: flag
  --help                          Get help on this command (type: flag)

Summary:

  Google App Engine deployment provider

Description:

  tbd

```

### Google Cloud Store

```
Usage: readme gcs [options]

Options:

  --access_key_id ID           GCS Interoperable Access Key ID (type: string, required: true)
  --secret_access_key KEY      GCS Interoperable Access Secret (type: string, required: true)
  --bucket BUCKET              GCS Bucket (type: string, required: true)
  --acl ACL                    Access control to set for uploaded objects (type: string)
  --upload_dir DIR             GCS directory to upload to (type: string, default: .)
  --local_dir DIR              Local directory to upload from. Can be an absolute (~/travis/build) or relative
                               (build) path. (type: string, default: .)
  --dot_match                  Upload hidden files starting with a dot (type: flag)
  --detect_encoding            HTTP header Content-Encoding to set for files compressed with gzip and compress
                               utilities. (type: flag)
  --cache_control HEADER       HTTP header Cache-Control to suggest that the browser cache the file. (type:
                               string)

Common Options:

  --app NAME                   type: string, default: repo name
  --key_name NAME              type: string, default: machine name
  --run CMD                    type: array (string, can be given multiple times)
  --skip-cleanup               type: flag
  --help                       Get help on this command (type: flag)

Summary:

  Google Cloud Store deployment provider

Description:

  tbd

```

### Hackage

```
Usage: readme hackage [options]

Options:

  --username USER      Hackage username (type: string, required: true)
  --password USER      Hackage password (type: string, required: true)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Hackage deployment provider

Description:

  tbd

```

### Hephy

```
Usage: readme hephy [options]

Options:

  --controller NAME      Hephy controller (type: string, required: true, e.g.: hephy.hephyapps.com)
  --username USER        Hephy username (type: string, required: true)
  --password PASS        Hephy password (type: string, required: true)
  --app APP              Hephy app (type: string)
  --cli_version VER      Install a specific hephy cli version (type: string, default: stable)
  --verbose              Verbose log output (type: flag)

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  Hephy deployment provider

Description:

  tbd

```

### Heroku API

```
Usage: readme heroku api [options]

Options:

  --api_key KEY          Heroku API key (type: string)
  --version VERSION      type: string

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --strategy NAME        Deployment strategy (type: string, default: api, known values: api, git)
  --app APP              Heroku app name (type: string, default: repo name)
  --log_level LEVEL      type: string
  --help                 Get help on this command (type: flag)

Summary:

  Heroku API deployment provider

Description:

  tbd

```

### Heroku Git

```
Usage: readme heroku git [options]

Options:

  Either api_key, or username and password are required.

  --api_key KEY          Heroku API key (type: string)
  --username USER        Heroku username (type: string, alias: user)
  --password PASS        Heroku password (type: string)
  --git URL              type: string

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --strategy NAME        Deployment strategy (type: string, default: api, known values: api, git)
  --app APP              Heroku app name (type: string, default: repo name)
  --log_level LEVEL      type: string
  --help                 Get help on this command (type: flag)

Summary:

  Heroku Git deployment provider

Description:

  tbd

```

### Launchpad

```
Usage: readme launchpad [options]

Options:

  --slug SLUG                      Launchpad project slug (type: string, format: /^~[^\/]+\/[^\/]+\/[^\/]+$/, e.g.:
                                   ~user-name/project-name/branch-name)
  --oauth_token TOKEN              Launchpad OAuth token (type: string)
  --oauth_token_secret SECRET      Launchpad OAuth token secret (type: string)

Common Options:

  --app NAME                       type: string, default: repo name
  --key_name NAME                  type: string, default: machine name
  --run CMD                        type: array (string, can be given multiple times)
  --skip-cleanup                   type: flag
  --help                           Get help on this command (type: flag)

Summary:

  Launchpad deployment provider

Description:

  tbd

```

<<<<<<< HEAD
### Minimal provider that executes a custom command

```
Usage: readme script [options]

Options:

  --script ./script      The script to execute (type: string, required: true)

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  Minimal provider that executes a custom command

Description:

  This deployment provider executes a single, custom command. This is
  usually a script that is contained in your repository, but it can be
  any command executable in the build environment.

  It is possible to pass arguments to a script deployment like so:

    dpl script -s './scripts/deploy.sh production --verbose'

  Deployment will be marked a failure if the script exits with nonzero
  status.

```

||||||| merged common ancestors
### Minimal provider that executes a custom command

```
Usage: readme script [options]

Options:

  --script ./script      The script to execute (type: string, required: true)

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  Minimal provider that executes a custom command

Description:

  This deployment provider executes a single, custom command. This is
  usually a script that is contained in your repository, but it can be
  any command executable in the build environment.
  
  It is possible to pass arguments to a script deployment like so:
  
    dpl script -s './scripts/deploy.sh production --verbose'
  
  Deployment will be marked a failure if the script exits with nonzero
  status.

```

=======
>>>>>>> make full_name a dsl method
### NPM

```
Usage: readme npm [options]

Options:

  --email EMAIL        NPM email address (type: string, required: true)
  --api_key KEY        NPM api key (can be retrieved from your local ~/.npmrc file) (type: string,
                       required: true)
  --tag TAGS           NPM distribution tags to add (type: string)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  NPM deployment provider

Description:

  tbd

```

### Open Shift

```
Usage: readme open_shift [options]

Options:

  --user NAME                     OpenShift username (type: string, required: true)
  --password PASS                 OpenShift password (type: string, required: true)
  --domain DOMAIN                 OpenShift application domain (type: string, required: true)
  --app APP                       OpenShift application (type: string, default: repo name)
  --deployment_branch BRANCH      type: string

Common Options:

  --app NAME                      type: string, default: repo name
  --key_name NAME                 type: string, default: machine name
  --run CMD                       type: array (string, can be given multiple times)
  --skip-cleanup                  type: flag
  --help                          Get help on this command (type: flag)

Summary:

  Open Shift deployment provider

Description:

  tbd

```

### Packagecloud

```
Usage: readme packagecloud [options]

Options:

  --username USER            The packagecloud.io username. (type: string, required: true)
  --token TOKEN              The packagecloud.io api token. (type: string, required: true)
  --repository REPO          The repository to push to. (type: string, required: true)
  --local_dir DIR            The sub-directory of the built assets for deployment. (type: string, default: .)
  --dist DIST                Required for debian, rpm, and node.js packages (use "node" for node.js
                             packages). The complete list of supported strings can be found on the
                             packagecloud.io docs. (type: string)
  --force                    Whether package has to be (re)uploaded / deleted before upload (type: flag)
  --connect_timeout SEC      type: integer, default: 60
  --read_timeout SEC         type: integer, default: 60
  --write_timeout SEC        type: integer, default: 180
  --package_glob GLOB        type: array (string, can be given multiple times), default: ["**/*"]

Common Options:

  --app NAME                 type: string, default: repo name
  --key_name NAME            type: string, default: machine name
  --run CMD                  type: array (string, can be given multiple times)
  --skip-cleanup             type: flag
  --help                     Get help on this command (type: flag)

Summary:

  Packagecloud deployment provider

Description:

  tbd

```

### Puppet Forge

```
Usage: readme puppet_forge [options]

Options:

  --user NAME          Puppet Forge user name (type: string, required: true)
  --password PASS      Puppet Forge password (type: string, required: true)
  --url URL            Puppet Forge URL to deploy to (type: string, default:
                       https://forgeapi.puppetlabs.com/)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Puppet Forge deployment provider

Description:

  tbd

```

### PyPI

```
Usage: readme pypi [options]

Options:

  --username NAME                   PyPI Username (type: string, required: true, alias: user)
  --password PASS                   PyPI Password (type: string, required: true)
  --server SERVER                   Release to a different index (type: string, default:
                                    https://upload.pypi.org/legacy/)
  --distributions DISTS             Space-separated list of distributions to be uploaded to PyPI (type: string,
                                    default: sdist)
  --[no-]skip_upload_docs BOOL      Skip uploading documentation. Note that upload.pypi.org does not support
                                    uploading documentation. (type: flag, default: true, see:
                                    https://github.com/travis-ci/dpl/issues/660)
  --docs_dir DIR                    Path to the directory to upload documentation from (type: string, default:
                                    build/docs)
  --skip_existing                   Do not overwrite an existing file with the same name on the server. (type: flag)
  --setuptools_version VER          type: string
  --twine_version VER               type: string
  --wheel_version VER               type: string

Common Options:

  --app NAME                        type: string, default: repo name
  --key_name NAME                   type: string, default: machine name
  --run CMD                         type: array (string, can be given multiple times)
  --skip-cleanup                    type: flag
  --help                            Get help on this command (type: flag)

Summary:

  PyPI deployment provider

Description:

  tbd

```

### Rubygems

```
Usage: readme rubygems [options]

Options:

  Either api_key, or user and password are required.

  --api_key KEY            Rubygems api key (type: string)
  --gem NAME               Name of the gem to release (type: string, default: repo name)
  --gemspec FILE           Gemspec file to use to build the gem (type: string)
  --gemspec_glob GLOB      Glob pattern to search for gemspec files when multiple gems are generated in the
                           repository (overrides the gemspec option) (type: string)
  --username USER          Rubygems user name (type: string, alias: user)
  --password PASS          Rubygems password (type: string)
  --host URL               type: string

Common Options:

  --app NAME               type: string, default: repo name
  --key_name NAME          type: string, default: machine name
  --run CMD                type: array (string, can be given multiple times)
  --skip-cleanup           type: flag
  --help                   Get help on this command (type: flag)

Summary:

  Rubygems deployment provider

Description:

  tbd

```

### Scalingo

```
Usage: readme scalingo [options]

Options:

  Either api_key, or username and password are required.

  --api_key KEY        scalingo API key (type: string, alias: api_token (deprecated, please use
                       api_key))
  --username NAME      scalingo username (type: string)
  --password PASS      scalingo password (type: string)
  --remote REMOTE      Remote url or git remote name of your git repository. (type: string, default:
                       scalingo)
  --branch BRANCH      Branch of your git repository. (type: string, default: master)
  --app APP            Required if your repository does not contain the appropriate remote (will add a
                       remote to your local repository) (type: string)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Scalingo deployment provider

Description:

  tbd

```

### Script

```
Usage: readme script [options]

Options:

  --script ./script      The script to execute (type: string, required: true)

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  Minimal provider that executes a custom command

Description:

  This deployment provider executes a single, custom command. This is
  usually a script that is contained in your repository, but it can be
  any command executable in the build environment.
  
  It is possible to pass arguments to a script deployment like so:
  
    dpl script -s './scripts/deploy.sh production --verbose'
  
  Deployment will be marked a failure if the script exits with nonzero
  status.

```

### Snap

```
Usage: readme snap [options]

Options:

  --snap STR           Path to the snap to be pushed (can be a glob) (type: string, required: true)
  --channel CHAN       Channel into which the snap will be released (type: string, default: edge)
  --token TOKEN        Snap API token (type: string, required: true)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Snap deployment provider

Description:

  tbd

```

### Surge

```
Usage: readme surge [options]

Options:

  --login EMAIL        Surge login (the email address you use with Surge) (type: string, required:
                       true)
  --token TOKEN        Surge login token (can be retrieved with `surge token`) (type: string, required:
                       true)
  --domain NAME        Domain to publish to. Not required if the domain is set in the CNAME file in the
                       project folder. (type: string)
  --project PAHT       Path to project directory relative to repo root (type: string, default: .)

Common Options:

  --app NAME           type: string, default: repo name
  --key_name NAME      type: string, default: machine name
  --run CMD            type: array (string, can be given multiple times)
  --skip-cleanup       type: flag
  --help               Get help on this command (type: flag)

Summary:

  Surge deployment provider

Description:

  tbd

```

### Testfairy

```
Usage: readme testfairy [options]

Options:

  --api_key KEY                       TestFairy API key (type: string, required: true)
  --app_file FILE                     Path to the app file that will be generated after the build (APK/IPA) (type:
                                      string, required: true)
  --symbols_file FILE                 Path to the symbols file (type: string)
  --testers_groups GROUPS             Tester groups to be notified about this build (type: string, e.g.: e.g.
                                      group1,group1)
  --notify                            Send an email with a changelog to your users (type: flag)
  --auto_update                       Automaticall upgrade all the previous installations of this app this version
                                      (type: flag)
  --video_quality QUALITY             Video quality settings (one of: high, medium or low (type: string, default:
                                      high)
  --screenshot_interval INTERVAL      Interval at which screenshots are taken, in seconds (type: integer, known
                                      values: 1, 2, 10)
  --max_duration DURATION             Maximum session recording length (max: 24h) (type: string, default: 10m, e.g.:
                                      20m or 1h)
  --data_only_wifi                    Send video and recorded metrics only when connected to a wifi network. (type:
                                      flag)
  --record_on_background              Collect data while the app is on background. (type: flag)
  --[no-]video                        Video recording settings (type: flag, default: true)
  --metrics METRICS                   Comma_separated list of metrics to record (type: string, see:
                                      http://docs.testfairy.com/Upload_API.html)
  --icon_watermark                    Add a small watermark to the app icon (type: flag)
  --advanced_options OPTS             Comma_separated list of advanced options (type: string, e.g.: option1,option2)

Common Options:

  --app NAME                          type: string, default: repo name
  --key_name NAME                     type: string, default: machine name
  --run CMD                           type: array (string, can be given multiple times)
  --skip-cleanup                      type: flag
  --help                              Get help on this command (type: flag)

Summary:

  Testfairy deployment provider

Description:

  tbd

```

### Transifex

```
Usage: readme transifex [options]

Options:

  --username NAME        Transifex username (type: string, required: true)
  --password PASS        Transifex password (type: string, required: true)
  --hostname NAME        Transifex hostname (type: string, default: www.transifex.com)
  --cli_version VER      CLI version to install (type: string, default: >=0.11)

Common Options:

  --app NAME             type: string, default: repo name
  --key_name NAME        type: string, default: machine name
  --run CMD              type: array (string, can be given multiple times)
  --skip-cleanup         type: flag
  --help                 Get help on this command (type: flag)

Summary:

  Transifex deployment provider

Description:

  tbd

```

## Development

TBD

## Credits

TBD

## License

Dpl is licensed under the [MIT License](https://github.com/travis-ci/dpl/blob/master/LICENSE).
