# Dpl [![Build Status](https://travis-ci.com/travis-ci/dpl.svg?branch=master)](https://travis-ci.com/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Coverage Status](https://coveralls.io/repos/travis-ci/dpl/badge.svg?branch=master&service=github&cache=2019-08-09_17:00)](https://coveralls.io/github/travis-ci/dpl?branch=master) [![Gem Version](https://img.shields.io/gem/v/dpl)](http://rubygems.org/gems/dpl) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/travis-ci/dpl)

This version of the README documents dpl v2, the next major version of dpl.
The REAMDE for dpl v1, the version that is currently used in production on
Travis CI can be found [here](https://github.com/travis-ci/dpl/blob/v1/README.md).

Dpl is command line tool for deploying code, html, packages, or build artifacts
to various service providers.

It is tightly integrated into Travis CI's [deployment integration](https://docs.travis-ci.com/user/deployment),
but also used, and recommended by others, such as [GitLab](https://docs.gitlab.com/ee/ci/examples/deployment/).

It is maintained by Travis CI, largely community driven, and it has existed
since 2013. If you find support your preferred deployment target missing,
please do not hesitate to get in touch, and we'll help you [add it](#contributing-to-dpl).

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Maturity Levels](#maturity-levels)
* [Supported Providers](#supported-providers)
* [Contributing to Dpl](#contributing-to-dpl)
* [Old Issues](#old-issues)
* [Code of Conduct](#code-of-conduct)
* [License](#license)
* [Credits](#credits)

## Requirements

Dpl requires Ruby 2.2 or later.

Depending on the deployment target dpl might require additional runtimes (e.g.
Go, Node.js, or Python) to be installed. It also might require sudo access in
order to install a Debian package.

Dpl is generally optimized for usage on Linux systems.

## Installation

Installation:

```
gem install dpl
```

## Usage

Dpl is meant and optimized for usage in ephemeral build environments, such
as Travis CI, or any other CI/CD pipeline.

Dpl is integrated to Travis CI's build configuration and build script compilation
tooling, so all you need to do is add the proper configuration to your `.travis.yml`
file. Please refer to [the documentation](https://docs.travis-ci.com/user/deployment)
for details.

For usage outside of Travis CI dpl can be executed as follows. Please refer to
the respective [providers](#supported-providers) for details.

```
dpl [provider] [options]
```

Dpl can be used locally, e.g. on your development machine, but it might leave
artifacts that may alter the behaviour of your system. If you encounter this
behaviour and it presents a serious issue to you then please open an
[issue](https://github.com/travis-ci/dpl/issues/new).

### Cleaning up the Git working directory

Dpl v1 has cleaned up the Git working directory by default, using `git stash
--all`. The default for this option has been changed in dpl v2, and users now
need to opt in to cleaning up any left over artifacts from the build process
by passing the option `--cleanup`.

The status of the working directory is relevant only to providers that package
and push it to the respective remote service (e.g. `heroku` when using the
`api` strategy, package registry providers, etc.). Most providers will either
push the latest Git commit, or pull code from a remote repository.

## Maturity Levels

In order to communicate the current development status and maturity of dpl's
support for a particular service the respective provider is marked with one of
the following maturity levels, according to the given criteria:

* `dev` - the provider is in development (initial level)
* `alpha` - the provider is fully tested
* `beta` - the provider has been in alpha for at least a month, and successful real-world production deployments have been observed
* `stable` - the provider has been in beta for at least two months, and there are no open issues that qualify as critical (such as deployments failing, documented functionality broken, etc)

## Supported Providers

Dpl supports the following providers:

  * [Anynines](#anynines)
  * [Atlas](#atlas)
  * [AWS Code Deploy](#aws-code-deploy)
  * [AWS Elastic Beanstalk](#aws-elastic-beanstalk)
  * [AWS Lambda](#aws-lambda)
  * [AWS OpsWorks](#aws-opsworks)
  * [AWS S3](#aws-s3)
  * [Azure Web Apps](#azure-web-apps)
  * [Bintray](#bintray)
  * [Bluemix Cloud Foundry](#bluemix-cloud-foundry)
  * [Boxfuse](#boxfuse)
  * [Cargo](#cargo)
  * [Chef Supermarket](#chef-supermarket)
  * [Cloud Files](#cloud-files)
  * [Cloud Foundry](#cloud-foundry)
  * [Cloud66](#cloud66)
  * [Datica](#datica)
  * [Engineyard](#engineyard)
  * [Firebase](#firebase)
  * [GitHub Pages](#github-pages)
  * [GitHub Releases](#github-releases)
  * [Google App Engine](#google-app-engine)
  * [Google Cloud Store](#google-cloud-store)
  * [Hackage](#hackage)
  * [Hephy](#hephy)
  * [Heroku API](#heroku-api)
  * [Heroku Git](#heroku-git)
  * [Launchpad](#launchpad)
  * [Netlify](#netlify)
  * [npm](#npm)
  * [OpenShift](#openshift)
  * [Packagecloud](#packagecloud)
  * [Puppet Forge](#puppet-forge)
  * [PyPI](#pypi)
  * [Rubygems](#rubygems)
  * [Scalingo](#scalingo)
  * [Script](#script)
  * [Snap](#snap)
  * [Surge](#surge)
  * [Testfairy](#testfairy)
  * [Transifex](#transifex)


### Anynines

```
Usage: dpl anynines [options]

Summary:

  Anynines deployment provider

Description:

  tbd

  Support for deployments to Anynines is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username USER         anynines username (type: string, required: true)
  --password PASS         anynines password (type: string, required: true)
  --organization ORG      anynines target organization (type: string, required: true)
  --space SPACE           anynines target space (type: string, required: true)
  --app_name APP          Application name (type: string)
  --buildpack PACK        Custom buildpack name or Git URL (type: string)
  --manifest FILE         Path to the manifest (type: string)

Common Options:

  --run CMD               Command to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --[no-]cleanup          Skip cleaning up build artifacts before the deployment
  --help                  Get help on this command

Examples:

  dpl anynines --username user --password pass --organization org --space space
  dpl anynines --username user --password pass --organization org --space space --app_name app
```

### Atlas

```
Usage: dpl atlas [options]

Summary:

  Atlas deployment provider

Description:

  tbd

  Support for deployments to Atlas is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --app APP            The Atlas application to upload to (type: string, required: true)
  --token TOKEN        The Atlas API token (type: string, required: true)
  --paths PATH         Files or directories to upload (type: array (string, can be given multiple
                       times), default: ["."])
  --address ADDR       The address of the Atlas server (type: string)
  --include GLOB       Glob pattern of files or directories to include (type: array (string, can be
                       given multiple times))
  --exclude GLOB       Glob pattern of files or directories to exclude (type: array (string, can be
                       given multiple times))
  --metadata DATA      Arbitrary key=value (string) metadata to be sent with the upload (type: array
                       (string, can be given multiple times))
  --[no-]vcs           Get lists of files to exclude and include from a VCS (Git, Mercurial or SVN)
  --args ARGS          Args to pass to the atlas-upload CLI (type: string)
  --[no-]debug         Turn on debug output

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl atlas --app app --token token
  dpl atlas --app app --token token --paths path --address addr --include glob
```

### AWS Code Deploy

```
Usage: dpl codedeploy [options]

Summary:

  AWS Code Deploy deployment provider

Description:

  tbd

  Support for deployments to AWS Code Deploy is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --access_key_id ID              AWS access key (type: string, required: true)
  --secret_access_key KEY         AWS secret access key (type: string, required: true)
  --application NAME              CodeDeploy application name (type: string, required: true)
  --deployment_group GROUP        CodeDeploy deployment group name (type: string)
  --revision_type TYPE            CodeDeploy revision type (type: string, known values: s3, github, downcase:
                                  true)
  --commit_id SHA                 Commit ID in case of GitHub (type: string)
  --repository NAME               Repository name in case of GitHub (type: string)
  --bucket NAME                   S3 bucket in case of S3 (type: string)
  --region REGION                 AWS availability zone (type: string, default: us-east-1)
  --file_exists_behavior STR      How to handle files that already exist in a deployment target location (type:
                                  string, default: disallow, known values: disallow, overwrite, retain)
  --[no-]wait_until_deployed      Wait until the deployment has finished
  --bundle_type TYPE              type: string
  --endpoint ENDPOINT             type: string
  --key KEY                       type: string
  --description DESCR             type: string

Common Options:

  --run CMD                       Command to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --[no-]cleanup                  Skip cleaning up build artifacts before the deployment
  --help                          Get help on this command

Examples:

  dpl codedeploy --access_key_id id --secret_access_key key --application name
  dpl codedeploy --access_key_id id --secret_access_key key --application name --deployment_group group --revision_type s3
```

### AWS Elastic Beanstalk

```
Usage: dpl elasticbeanstalk [options]

Summary:

  AWS Elastic Beanstalk deployment provider

Description:

  tbd

  Support for deployments to AWS Elastic Beanstalk is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --access_key_id ID                  AWS Access Key ID (type: string, required: true)
  --secret_access_key KEY             AWS Secret Key (type: string, required: true)
  --region REGION                     AWS Region the Elastic Beanstalk app is running in (type: string, default:
                                      us-east-1)
  --app NAME                          Elastic Beanstalk application name (type: string, default: repo name)
  --env NAME                          Elastic Beanstalk environment name which will be updated (type: string,
                                      required: true)
  --bucket NAME                       Bucket name to upload app to (type: string, required: true, alias: bucket_name)
  --bucket_path PATH                  Location within Bucket to upload app to (type: string)
  --description DESC                  Description for the application version (type: string)
  --label LABEL                       Label for the application version (type: string)
  --zip_file PATH                     The zip file that you want to deploy (type: string)
  --[no-]only_create_app_version      Only create the app version, do not actually deploy it
  --[no-]wait_until_deployed          Wait until the deployment has finished

Common Options:

  --run CMD                           Command to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --[no-]cleanup                      Skip cleaning up build artifacts before the deployment
  --help                              Get help on this command

Examples:

  dpl elasticbeanstalk --access_key_id id --secret_access_key key --env name --bucket name
  dpl elasticbeanstalk --access_key_id id --secret_access_key key --env name --bucket name --region region
```

### AWS Lambda

```
Usage: dpl lambda [options]

Summary:

  AWS Lambda deployment provider

Description:

  tbd

  Support for deployments to AWS Lambda is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --access_key_id ID            AWS access key id (type: string, required: true)
  --secret_access_key KEY       AWS secret key (type: string, required: true)
  --region REGION               AWS region the Lambda function is running in (type: string, default: us-east-1)
  --function_name FUNC          Name of the Lambda being created or updated (type: string, required: true)
  --role ROLE                   ARN of the IAM role to assign to the Lambda function (type: string, note:
                                required for creating a new function)
  --handler_name NAME           Function the Lambda calls to begin execution. (type: string, note: required for
                                creating a new function)
  --module_name NAME            Name of the module that exports the handler (type: string, requires:
                                handler_name, default: index)
  --description DESCR           Description of the Lambda being created or updated (type: string)
  --timeout SECS                Function execution time (in seconds) at which Lambda should terminate the
                                function (type: string, default: 3)
  --memory_size MB              Amount of memory in MB to allocate to this Lambda (type: string, default: 128)
  --subnet_ids IDS              List of subnet IDs to be added to the function (type: array (string, can be
                                given multiple times), note: Needs the ec2:DescribeSubnets and ec2:DescribeVpcs
                                permission for the user of the access/secret key to work)
  --security_group_ids IDS      List of security group IDs to be added to the function (type: array (string, can
                                be given multiple times), note: Needs the ec2:DescribeSecurityGroups and
                                ec2:DescribeVpcs permission for the user of the access/secret key to work)
  --environment VARS            List of Environment Variables to add to the function (type: array (string, can
                                be given multiple times), alias: environment_variables, format: /[\w\-]+=.+/,
                                note: Can be encrypted for added security)
  --runtime NAME                Lambda runtime to use (type: string, default: nodejs8.10, known values: java8,
                                nodejs8.10, nodejs10.x, python2.7, python3.6, python3.7, dotnetcore2.1, go1.x,
                                ruby2.5)
  --dead_letter_arn ARN         ARN to an SNS or SQS resource used for the dead letter queue. (type: string)
  --kms_key_arn ARN             KMS key ARN to use to encrypt environment_variables. (type: string)
  --tracing_mode MODE           Tracing mode (type: string, default: PassThrough, known values: Active,
                                PassThrough, note: Needs xray:PutTraceSegments xray:PutTelemetryRecords on the
                                role)
  --layers LAYERS               Function layer arns (type: array (string, can be given multiple times))
  --function_tags TAGS          List of tags to add to the function (type: array (string, can be given multiple
                                times), format: /[\w\-]+=.+/, note: Can be encrypted for added security)
  --[no-]publish                Create a new version of the code instead of replacing the existing one.
  --zip PATH                    Path to a packaged Lambda, a directory to package, or a single file to package
                                (type: string, default: .)
  --[no-]dot_match              Include hidden .* files to the zipped archive

Common Options:

  --run CMD                     Command to execute after the deployment finished successfully (type: array
                                (string, can be given multiple times))
  --[no-]cleanup                Skip cleaning up build artifacts before the deployment
  --help                        Get help on this command

Examples:

  dpl lambda --access_key_id id --secret_access_key key --function_name func
  dpl lambda --access_key_id id --secret_access_key key --function_name func --region region --role role
```

### AWS OpsWorks

```
Usage: dpl opsworks [options]

Summary:

  AWS OpsWorks deployment provider

Description:

  tbd

  Support for deployments to AWS OpsWorks is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --access_key_id ID              AWS access key id (type: string, required: true)
  --secret_access_key KEY         AWS secret key (type: string, required: true)
  --app_id APP                    The app id (type: string, required: true)
  --region REGION                 AWS region (type: string, default: us-east-1)
  --instance_ids ID               An instance id (type: array (string, can be given multiple times))
  --layer_ids ID                  A layer id (type: array (string, can be given multiple times))
  --[no-]migrate                  Migrate the database.
  --[no-]wait_until_deployed      Wait until the app is deployed and return the deployment status.
  --[no-]update_on_success        When wait-until-deployed and updated-on-success are both not given, application
                                  source is updated to the current SHA. Ignored when wait-until-deployed is not
                                  given. (alias: update_app_on_success)
  --custom_json JSON              Custom json options override (overwrites default configuration) (type: string)

Common Options:

  --run CMD                       Command to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --[no-]cleanup                  Skip cleaning up build artifacts before the deployment
  --help                          Get help on this command

Examples:

  dpl opsworks --access_key_id id --secret_access_key key --app_id app
  dpl opsworks --access_key_id id --secret_access_key key --app_id app --region region --instance_ids id
```

### AWS S3

```
Usage: dpl s3 [options]

Summary:

  AWS S3 deployment provider

Description:

  tbd

  Support for deployments to AWS S3 is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --access_key_id ID                  AWS access key id (type: string, required: true)
  --secret_access_key KEY             AWS secret key (type: string, required: true)
  --bucket BUCKET                     S3 bucket (type: string, required: true)
  --region REGION                     S3 region (type: string, default: us-east-1)
  --endpoint URL                      S3 endpoint (type: string)
  --upload_dir DIR                    S3 directory to upload to (type: string)
  --storage_class CLASS               S3 storage class to upload as (type: string, default: STANDARD, known values:
                                      STANDARD, STANDARD_IA, REDUCED_REDUNDANCY)
  --[no-]server_side_encryption       Use S3 Server Side Encryption (SSE-AES256)
  --local_dir DIR                     Local directory to upload from (type: string, default: ., e.g.: ~/travis/build
                                      (absolute path) or ./build (relative path))
  --[no-]detect_encoding              HTTP header Content-Encoding for files compressed with gzip and compress
                                      utilities
  --cache_control STR                 HTTP header Cache-Control to suggest that the browser cache the file (type:
                                      array (string, can be given multiple times), default: no-cache, known values:
                                      /^no-cache.*/, /^no-store.*/, /^max-age=\d+.*/, /^s-maxage=\d+.*/,
                                      /^no-transform/, /^public/, /^private/, note: accepts mapping values to globs)
  --expires DATE                      Date and time that the cached object expires (type: array (string, can be given
                                      multiple times), format: /^"?\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .+"?.*$/, note:
                                      accepts mapping values to globs)
  --acl ACL                           Access control for the uploaded objects (type: string, default: private, known
                                      values: private, public_read, public_read_write, authenticated_read,
                                      bucket_owner_read, bucket_owner_full_control)
  --[no-]dot_match                    Upload hidden files starting with a dot
  --index_document_suffix SUFFIX      Index document suffix of a S3 website (type: string)
  --default_text_charset CHARSET      Default character set to append to the content-type of text files (type: string)
  --max_threads NUM                   The number of threads to use for S3 file uploads (type: integer, default: 5,
                                      max: 15)
  --[no-]overwrite                    Whether or not to overwrite existing files (default: true)
  --[no-]verbose                      Be verbose about uploading files

Common Options:

  --run CMD                           Command to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --[no-]cleanup                      Skip cleaning up build artifacts before the deployment
  --help                              Get help on this command

Examples:

  dpl s3 --access_key_id id --secret_access_key key --bucket bucket
  dpl s3 --access_key_id id --secret_access_key key --bucket bucket --region region --endpoint url
```

### Azure Web Apps

```
Usage: dpl azure_web_apps [options]

Summary:

  Azure Web Apps deployment provider

Description:

  tbd

  Support for deployments to Azure Web Apps is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --site SITE          Web App name (e.g. myapp in myapp.azurewebsites.net) (type: string, required:
                       true)
  --username NAME      Web App Deployment Username (type: string, required: true)
  --password PASS      Web App Deployment Password (type: string, required: true)
  --slot SLOT          Slot name (if your app uses staging deployment) (type: string)
  --[no-]verbose       Print deployment output from Azure. Warning: If authentication fails, Git prints
                       credentials in clear text. Correct credentials remain hidden.

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl azure_web_apps --site site --username name --password pass
  dpl azure_web_apps --site site --username name --password pass --slot slot --verbose
```

### Bintray

```
Usage: dpl bintray [options]

Summary:

  Bintray deployment provider

Description:

  tbd

  Support for deployments to Bintray is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --user USER              Bintray user (type: string, required: true)
  --key KEY                Bintray API key (type: string, required: true)
  --file FILE              Path to a descriptor file for the Bintray upload (type: string, required: true)
  --passphrase PHRASE      Passphrase as configured on Bintray (if GPG signing is used) (type: string)

Common Options:

  --run CMD                Command to execute after the deployment finished successfully (type: array
                           (string, can be given multiple times))
  --[no-]cleanup           Skip cleaning up build artifacts before the deployment
  --help                   Get help on this command

Examples:

  dpl bintray --user user --key key --file file
  dpl bintray --user user --key key --file file --passphrase phrase --run cmd
```

### Bluemix Cloud Foundry

```
Usage: dpl bluemixcloudfoundry [options]

Summary:

  Bluemix Cloud Foundry deployment provider

Description:

  tbd

  Support for deployments to Bluemix Cloud Foundry is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username USER                 Bluemix username (type: string, required: true)
  --password PASS                 Bluemix password (type: string, required: true)
  --organization ORG              Bluemix target organization (type: string, required: true)
  --space SPACE                   Bluemix target space (type: string, required: true)
  --region REGION                 Bluemix region (type: string, default: ng, known values: ng, eu-gb, eu-de,
                                  au-syd)
  --api URL                       Bluemix api URL (type: string)
  --app_name APP                  Application name (type: string)
  --buildpack PACK                Custom buildpack name or Git URL (type: string)
  --manifest FILE                 Path to the manifest (type: string)
  --[no-]skip_ssl_validation      Skip SSL validation

Common Options:

  --run CMD                       Command to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --[no-]cleanup                  Skip cleaning up build artifacts before the deployment
  --help                          Get help on this command

Examples:

  dpl bluemixcloudfoundry --username user --password pass --organization org --space space
  dpl bluemixcloudfoundry --username user --password pass --organization org --space space --region ng
```

### Boxfuse

```
Usage: dpl boxfuse [options]

Summary:

  Boxfuse deployment provider

Description:

  tbd

  Support for deployments to Boxfuse is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --user USER             type: string, required: true
  --secret SECRET         type: string, required: true
  --config_file FILE      type: string, alias: configfile (deprecated, please use config_file)
  --payload PAYLOAD       type: string
  --app APP               type: string
  --version VERSION       type: string
  --env ENV               type: string
  --extra_args ARGS       type: string

Common Options:

  --run CMD               Command to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --[no-]cleanup          Skip cleaning up build artifacts before the deployment
  --help                  Get help on this command

Examples:

  dpl boxfuse --user user --secret secret
  dpl boxfuse --user user --secret secret --config_file file --payload payload --app app
```

### Cargo

```
Usage: dpl cargo [options]

Summary:

  Cargo deployment provider

Description:

  tbd

  Support for deployments to Cargo is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --token TOKEN       Cargo registry API token (type: string, required: true)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --[no-]cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl cargo --token token
  dpl cargo --token token --run cmd --cleanup
```

### Chef Supermarket

```
Usage: dpl chef_supermarket [options]

Summary:

  Chef Supermarket deployment provider

Description:

  tbd

  Support for deployments to Chef Supermarket is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --user_id ID          Chef Supermarket user name (type: string, required: true)
  --client_key KEY      Client API key file name (type: string, required: true)
  --name NAME           Cookbook name (type: string, alias: cookbook_name, note: defaults to the name
                        given in metadata.json or metadata.rb)
  --category CAT        Cookbook category in Supermarket (type: string, required: true, alias:
                        cookbook_category, see: https://docs.getchef.com/knife_cookbook_site.html#id12)
  --dir DIR             Directory containing the cookbook (type: string, default: .)

Common Options:

  --run CMD             Command to execute after the deployment finished successfully (type: array
                        (string, can be given multiple times))
  --[no-]cleanup        Skip cleaning up build artifacts before the deployment
  --help                Get help on this command

Examples:

  dpl chef_supermarket --user_id id --client_key key --category cat
  dpl chef_supermarket --user_id id --client_key key --category cat --name name --dir dir
```

### Cloud Files

```
Usage: dpl cloudfiles [options]

Summary:

  Cloud Files deployment provider

Description:

  tbd

  Support for deployments to Cloud Files is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username USER       Rackspace username (type: string, required: true)
  --api_key KEY         Rackspace API key (type: string, required: true)
  --region REGION       Cloudfiles region (type: string, required: true, known values: ord, dfw, syd,
                        iad, hkg)
  --container NAME      Name of the container that files will be uploaded to (type: string, required:
                        true)
  --glob GLOB           Paths to upload (type: string, default: **/*)
  --[no-]dot_match      Upload hidden files starting a dot

Common Options:

  --run CMD             Command to execute after the deployment finished successfully (type: array
                        (string, can be given multiple times))
  --[no-]cleanup        Skip cleaning up build artifacts before the deployment
  --help                Get help on this command

Examples:

  dpl cloudfiles --username user --api_key key --region ord --container name
  dpl cloudfiles --username user --api_key key --region ord --container name --glob glob
```

### Cloud Foundry

```
Usage: dpl cloudfoundry [options]

Summary:

  Cloud Foundry deployment provider

Description:

  tbd

  Support for deployments to Cloud Foundry is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username USER                 Cloud Foundry username (type: string, required: true)
  --password PASS                 Cloud Foundry password (type: string, required: true)
  --organization ORG              Cloud Foundry target organization (type: string, required: true)
  --space SPACE                   Cloud Foundry target space (type: string, required: true)
  --api URL                       Cloud Foundry api URL (type: string, required: true)
  --app_name APP                  Application name (type: string)
  --buildpack PACK                Custom buildpack name or Git URL (type: string)
  --manifest FILE                 Path to the manifest (type: string)
  --[no-]skip_ssl_validation      Skip SSL validation
  --[no-]v3                       Use the v3 API version to push the application

Common Options:

  --run CMD                       Command to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --[no-]cleanup                  Skip cleaning up build artifacts before the deployment
  --help                          Get help on this command

Examples:

  dpl cloudfoundry --username user --password pass --organization org --space space --api url
```

### Cloud66

```
Usage: dpl cloud66 [options]

Summary:

  Cloud66 deployment provider

Description:

  tbd

  Support for deployments to Cloud66 is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --redeployment_hook URL      The redeployment hook URL (type: string, required: true)

Common Options:

  --run CMD                    Command to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --[no-]cleanup               Skip cleaning up build artifacts before the deployment
  --help                       Get help on this command

Examples:

  dpl cloud66 --redeployment_hook url
  dpl cloud66 --redeployment_hook url --run cmd --cleanup
```

### Datica

```
Usage: dpl datica [options]

Summary:

  Datica deployment provider

Description:

  tbd

  Support for deployments to Datica is in development. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --target TARGET      The git remote repository to deploy to (type: string, required: true)
  --path PATH          Path to files to deploy (type: string, default: .)

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl datica --target target
  dpl datica --target target --path path --run cmd --cleanup
```

### Engineyard

```
Usage: dpl engineyard [options]

Summary:

  Engineyard deployment provider

Description:

  tbd

  Support for deployments to Engineyard is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either api_key, or email and password are required.

  --api_key KEY        Engine Yard API key (type: string)
  --email EMAIL        Engine Yard account email (type: string)
  --password PASS      Engine Yard password (type: string)
  --app APP            Engine Yard application name (type: string, default: repo name)
  --env ENV            Engine Yard application environment (type: string, alias: environment)
  --migrate CMD        Engine Yard migration commands (type: string)
  --account NAME       Engine Yard account name (type: string)

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl engineyard --api_key key
  dpl engineyard --email email --password pass
  dpl engineyard --api_key key --app app --env env --migrate cmd --account name
```

### Firebase

```
Usage: dpl firebase [options]

Summary:

  Firebase deployment provider

Description:

  tbd

  Support for deployments to Firebase is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --token TOKEN        Firebase CI access token (generate with firebase login:ci) (type: string,
                       required: true)
  --project NAME       Firebase project to deploy to (defaults to the one specified in your
                       firebase.json) (type: string)
  --message MSG        Message describing this deployment. (type: string)
  --only SERVICES      Firebase services to deploy (type: string, note: can be a comma-separated list)
  --[no-]force         Whether or not to delete Cloud Functions missing from the current working
                       directory

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl firebase --token token
  dpl firebase --token token --project name --message msg --only services --force
```

### GitHub Pages

```
Usage: dpl pages [options]

Summary:

  GitHub Pages deployment provider

Description:

  tbd

  Support for deployments to GitHub Pages is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either github_token, or deploy_key are required.

  --github_token TOKEN           GitHub oauth token with repo permission (type: string)
  --deploy_key KEY               A base64-encoded, private deploy key with write access to the repository (type:
                                 string, note: RSA keys are too long to fit into a Travis CI secure variable, but
                                 ECDSA-521 fits, see:
                                 https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys)
  --repo SLUG                    Repo slug (type: string, default: repo slug)
  --target_branch BRANCH         Branch to push force to (type: string, default: gh-pages)
  --[no-]keep_history            Create incremental commit instead of doing push force (default: true)
  --commit_message MSG           type: string, default: Deploy %{project_name} to %{url}:%{target_branch}
  --[no-]allow_empty_commit      Allow an empty commit to be created (requires: keep_history)
  --[no-]committer_from_gh       Use the token's owner name and email for commit. Overrides the email and name
                                 options
  --[no-]verbose                 Be verbose about the deploy process
  --local_dir DIR                Directory to push to GitHub Pages (type: string, default: .)
  --fqdn FQDN                    Writes your website's domain name to the CNAME file (type: string)
  --project_name NAME            Used in the commit message only (defaults to fqdn or the current repo slug)
                                 (type: string)
  --email EMAIL                  Committer email (type: string, default: deploy@travis-ci.org)
  --name NAME                    Committer name (type: string, default: Deploy Bot)
  --[no-]deployment_file         Enable creation of a deployment-info file
  --github_url URL               type: string, default: github.com

Common Options:

  --run CMD                      Command to execute after the deployment finished successfully (type: array
                                 (string, can be given multiple times))
  --[no-]cleanup                 Skip cleaning up build artifacts before the deployment
  --help                         Get help on this command

Examples:

  dpl pages --github_token token
  dpl pages --deploy_key key
  dpl pages --github_token token --repo slug --target_branch branch --keep_history --commit_message msg
```

### GitHub Releases

```
Usage: dpl releases [options]

Summary:

  GitHub Releases deployment provider

Description:

  tbd

  Support for deployments to GitHub Releases is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either api_key, or user and password are required.

  --api_key TOKEN                GitHub oauth token (needs public_repo or repo permission) (type: string)
  --username LOGIN               GitHub login name (type: string, alias: user)
  --password PASS                GitHub password (type: string)
  --repo SLUG                    GitHub repo slug (type: string, default: repo slug)
  --file FILE                    File to release to GitHub (type: array (string, can be given multiple times),
                                 required: true)
  --[no-]file_glob               Interpret files as globs
  --[no-]overwrite               Overwrite files with the same name
  --[no-]prerelease              Identify the release as a prerelease
  --release_number NUM           Release number (overide automatic release detection) (type: string)
  --release_notes STR            Content for the release notes (type: string, alias: body)
  --release_notes_file PATH      Path to a file containing the release notes (type: string, note: will be ignored
                                 if --release_notes is given)
  --[no-]draft                   Identify the release as a draft
  --tag_name TAG                 Git tag from which to create the release (type: string)
  --target_commitish STR         Commitish value that determines where the Git tag is created from (type: string)
  --name NAME                    Name for the release (type: string)

Common Options:

  --run CMD                      Command to execute after the deployment finished successfully (type: array
                                 (string, can be given multiple times))
  --[no-]cleanup                 Skip cleaning up build artifacts before the deployment
  --help                         Get help on this command

Examples:

  dpl releases --file file --api_key token
  dpl releases --file file --password pass
  dpl releases --file file
  dpl releases --file file --api_key token --username login --repo slug --file_glob
```

### Google App Engine

```
Usage: dpl gae [options]

Summary:

  Google App Engine deployment provider

Description:

  tbd

  Support for deployments to Google App Engine is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --project ID                      Project ID used to identify the project on Google Cloud (type: string, required:
                                    true)
  --keyfile FILE                    Path to the JSON file containing your Service Account credentials in JSON Web
                                    Token format. To be obtained via the Google Developers Console. Should be
                                    handled with care as it contains authorization keys. (type: string, default:
                                    service-account.json)
  --config FILE                     Path to your service configuration file (type: array (string, can be given
                                    multiple times), default: app.yaml)
  --version VER                     The version of the app that will be created or replaced by this deployment. If
                                    you do not specify a version, one will be generated for you (type: string)
  --verbosity LEVEL                 Adjust the log verbosity (type: string, default: warning)
  --[no-]promote                    Do not promote the deployed version (default: true)
  --[no-]stop_previous_version      Prevent your deployment from stopping the previously promoted version. This is
                                    from the future, so might not work (yet). (default: true)
  --[no-]install_sdk                Do not install the Google Cloud SDK (default: true)

Common Options:

  --run CMD                         Command to execute after the deployment finished successfully (type: array
                                    (string, can be given multiple times))
  --[no-]cleanup                    Skip cleaning up build artifacts before the deployment
  --help                            Get help on this command

Examples:

  dpl gae --project id
  dpl gae --project id --keyfile file --config file --version ver --verbosity level
```

### Google Cloud Store

```
Usage: dpl gcs [options]

Summary:

  Google Cloud Store deployment provider

Description:

  tbd

  Support for deployments to Google Cloud Store is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --access_key_id ID           GCS Interoperable Access Key ID (type: string, required: true)
  --secret_access_key KEY      GCS Interoperable Access Secret (type: string, required: true)
  --bucket BUCKET              GCS Bucket (type: string, required: true)
  --local_dir DIR              Local directory to upload from (type: string, default: .)
  --upload_dir DIR             GCS directory to upload to (type: string)
  --[no-]dot_match             Upload hidden files starting with a dot
  --acl ACL                    Access control to set for uploaded objects (type: string)
  --[no-]detect_encoding       HTTP header Content-Encoding to set for files compressed with gzip and compress
                               utilities.
  --cache_control HEADER       HTTP header Cache-Control to suggest that the browser cache the file. (type:
                               string)

Common Options:

  --run CMD                    Command to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --[no-]cleanup               Skip cleaning up build artifacts before the deployment
  --help                       Get help on this command

Examples:

  dpl gcs --access_key_id id --secret_access_key key --bucket bucket
  dpl gcs --access_key_id id --secret_access_key key --bucket bucket --local_dir dir --upload_dir dir
```

### Hackage

```
Usage: dpl hackage [options]

Summary:

  Hackage deployment provider

Description:

  tbd

  Support for deployments to Hackage is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username USER      Hackage username (type: string, required: true)
  --password USER      Hackage password (type: string, required: true)
  --[no-]publish       Whether or not to publish the package

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl hackage --username user --password user
  dpl hackage --username user --password user --publish --run cmd --cleanup
```

### Hephy

```
Usage: dpl hephy [options]

Summary:

  Hephy deployment provider

Description:

  tbd

  Support for deployments to Hephy is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --controller NAME      Hephy controller (type: string, required: true, e.g.: hephy.hephyapps.com)
  --username USER        Hephy username (type: string, required: true)
  --password PASS        Hephy password (type: string, required: true)
  --app APP              Deis app (type: string, required: true)
  --cli_version VER      Install a specific hephy cli version (type: string, default: stable)
  --[no-]verbose         Verbose log output

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --[no-]cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl hephy --controller name --username user --password pass --app app
  dpl hephy --controller name --username user --password pass --app app --cli_version ver
```

### Heroku API

```
Usage: dpl heroku api [options]

Summary:

  Heroku API deployment provider

Description:

  tbd

  Support for deployments to Heroku API is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --api_key KEY       Heroku API key (type: string, required: true)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --[no-]cleanup      Skip cleaning up build artifacts before the deployment
  --app APP           Heroku app name (type: string, default: repo name)
  --help              Get help on this command

Examples:

  dpl heroku api --api_key key
  dpl heroku api --api_key key --run cmd --cleanup --app app
```

### Heroku Git

```
Usage: dpl heroku git [options]

Summary:

  Heroku Git deployment provider

Description:

  tbd

  Support for deployments to Heroku Git is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either api_key, or username and password are required.

  --api_key KEY        Heroku API key (type: string)
  --username USER      Heroku username (type: string, alias: user)
  --password PASS      Heroku password (type: string)
  --git URL            type: string

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --app APP            Heroku app name (type: string, default: repo name)
  --help               Get help on this command

Examples:

  dpl heroku git --api_key key
  dpl heroku git --username user --password pass
  dpl heroku git --api_key key --git url --run cmd --cleanup --app app
```

### Launchpad

```
Usage: dpl launchpad [options]

Summary:

  Launchpad deployment provider

Description:

  tbd

  Support for deployments to Launchpad is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --slug SLUG                      Launchpad project slug (type: string, format: /^~[^\/]+\/[^\/]+\/[^\/]+$/, e.g.:
                                   ~user-name/project-name/branch-name)
  --oauth_token TOKEN              Launchpad OAuth token (type: string)
  --oauth_token_secret SECRET      Launchpad OAuth token secret (type: string)

Common Options:

  --run CMD                        Command to execute after the deployment finished successfully (type: array
                                   (string, can be given multiple times))
  --[no-]cleanup                   Skip cleaning up build artifacts before the deployment
  --help                           Get help on this command

Examples:

  dpl launchpad --slug slug --oauth_token token --oauth_token_secret secret --run cmd --cleanup
```

### Netlify

```
Usage: dpl netlify [options]

Summary:

  Netlify deployment provider

Description:

  tbd

  Support for deployments to Netlify is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --site ID              A site ID to deploy to (type: string, required: true)
  --auth TOKEN           An auth token to log in with (type: string, required: true)
  --dir DIR              Specify a folder to deploy (type: string)
  --functions FUNCS      Specify a functions folder to deploy (type: string)
  --message MSG          A message to include in the deploy log (type: string)
  --[no-]prod            Deploy to production

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --[no-]cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl netlify --site id --auth token
  dpl netlify --site id --auth token --dir dir --functions funcs --message msg
```

### npm

```
Usage: dpl npm [options]

Summary:

  npm deployment provider

Description:

  tbd

  Support for deployments to npm is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --email EMAIL           npm account email (type: string)
  --api_token TOKEN       npm api token (type: string, required: true, alias: api_key, note: can be
                          retrieved from your local ~/.npmrc file, see:
                          https://docs.npmjs.com/creating-and-viewing-authentication-tokens)
  --access ACCESS         Access level (type: string, known values: public, private)
  --registry URL          npm registry url (type: string)
  --src SRC               directory or tarball to publish (type: string, default: .)
  --tag TAGS              distribution tags to add (type: string)
  --[no-]auth_method      Authentication method (known values: auth)

Common Options:

  --run CMD               Command to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --[no-]cleanup          Skip cleaning up build artifacts before the deployment
  --help                  Get help on this command

Examples:

  dpl npm --api_token token
  dpl npm --api_token token --email email --access public --registry url --src src
```

### OpenShift

```
Usage: dpl openshift [options]

Summary:

  OpenShift deployment provider

Description:

  tbd

  Support for deployments to OpenShift is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --server SERVER        OpenShift server (type: string, required: true)
  --token TOKEN          OpenShift token (type: string, required: true)
  --project PROJECT      OpenShift project (type: string, required: true)
  --app APP              OpenShift application (type: string, default: repo name)

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --[no-]cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl openshift --server server --token token --project project
  dpl openshift --server server --token token --project project --app app --run cmd
```

### Packagecloud

```
Usage: dpl packagecloud [options]

Summary:

  Packagecloud deployment provider

Description:

  tbd

  Support for deployments to Packagecloud is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username USER            The packagecloud.io username. (type: string, required: true)
  --token TOKEN              The packagecloud.io api token. (type: string, required: true)
  --repository REPO          The repository to push to. (type: string, required: true)
  --local_dir DIR            The sub-directory of the built assets for deployment. (type: string, default: .)
  --dist DIST                Required for debian, rpm, and node.js packages (use "node" for node.js
                             packages). The complete list of supported strings can be found on the
                             packagecloud.io docs. (type: string)
  --[no-]force               Whether package has to be (re)uploaded / deleted before upload
  --connect_timeout SEC      type: integer, default: 60
  --read_timeout SEC         type: integer, default: 60
  --write_timeout SEC        type: integer, default: 180
  --package_glob GLOB        type: array (string, can be given multiple times), default: ["**/*"]

Common Options:

  --run CMD                  Command to execute after the deployment finished successfully (type: array
                             (string, can be given multiple times))
  --[no-]cleanup             Skip cleaning up build artifacts before the deployment
  --help                     Get help on this command

Examples:

  dpl packagecloud --username user --token token --repository repo
  dpl packagecloud --username user --token token --repository repo --local_dir dir --dist dist
```

### Puppet Forge

```
Usage: dpl puppetforge [options]

Summary:

  Puppet Forge deployment provider

Description:

  tbd

  Support for deployments to Puppet Forge is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username NAME      Puppet Forge user name (type: string, required: true, alias: user)
  --password PASS      Puppet Forge password (type: string, required: true)
  --url URL            Puppet Forge URL to deploy to (type: string, default:
                       https://forgeapi.puppetlabs.com/)

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --[no-]cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl puppetforge --username name --password pass
  dpl puppetforge --username name --password pass --url url --run cmd --cleanup
```

### PyPI

```
Usage: dpl pypi [options]

Summary:

  PyPI deployment provider

Description:

  tbd

  Support for deployments to PyPI is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --username NAME               PyPI Username (type: string, required: true, alias: user)
  --password PASS               PyPI Password (type: string, required: true)
  --server SERVER               Release to a different index (type: string, default:
                                https://upload.pypi.org/legacy/)
  --distributions DISTS         Space-separated list of distributions to be uploaded to PyPI (type: string,
                                default: sdist)
  --docs_dir DIR                Path to the directory to upload documentation from (type: string, default:
                                build/docs)
  --[no-]skip_existing          Do not overwrite an existing file with the same name on the server.
  --[no-]upload_docs            Upload documentation (default: false, note: most PyPI servers, including
                                upload.pypi.org, do not support uploading documentation)
  --[no-]twine_check            Whether to run twine check (default: true)
  --[no-]remove_build_dir       Remove the build dir after the upload (default: true)
  --setuptools_version VER      type: string, format: /\A\d+(?:\.\d+)*\z/
  --twine_version VER           type: string, format: /\A\d+(?:\.\d+)*\z/
  --wheel_version VER           type: string, format: /\A\d+(?:\.\d+)*\z/

Common Options:

  --run CMD                     Command to execute after the deployment finished successfully (type: array
                                (string, can be given multiple times))
  --[no-]cleanup                Skip cleaning up build artifacts before the deployment
  --help                        Get help on this command

Examples:

  dpl pypi --username name --password pass
  dpl pypi --username name --password pass --server server --distributions dists --docs_dir dir
```

### Rubygems

```
Usage: dpl rubygems [options]

Summary:

  Rubygems deployment provider

Description:

  tbd

  Support for deployments to Rubygems is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either api_key, or user and password are required.

  --api_key KEY            Rubygems api key (type: string)
  --username USER          Rubygems user name (type: string, alias: user)
  --password PASS          Rubygems password (type: string)
  --gem NAME               Name of the gem to release (type: string, default: repo name)
  --gemspec FILE           Gemspec file to use to build the gem (type: string)
  --gemspec_glob GLOB      Glob pattern to search for gemspec files when multiple gems are generated in the
                           repository (overrides the gemspec option) (type: string)
  --host URL               type: string

Common Options:

  --run CMD                Command to execute after the deployment finished successfully (type: array
                           (string, can be given multiple times))
  --[no-]cleanup           Skip cleaning up build artifacts before the deployment
  --help                   Get help on this command

Examples:

  dpl rubygems --api_key key
  dpl rubygems --password pass
  dpl rubygems --api_key key --username user --gem name --gemspec file --gemspec_glob glob
```

### Scalingo

```
Usage: dpl scalingo [options]

Summary:

  Scalingo deployment provider

Description:

  tbd

  Support for deployments to Scalingo is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either api_token, or username and password are required.

  --app APP              type: string, default: repo name
  --api_token TOKEN      Scalingo API token (type: string, alias: api_key (deprecated, please use
                         api_token))
  --username NAME        Scalingo username (type: string)
  --password PASS        Scalingo password (type: string)
  --region REGION        Scalingo region (type: string, default: agora-fr1, known values: agora-fr1,
                         osc-fr1)
  --remote REMOTE        Git remote name (type: string, default: scalingo-dpl)
  --branch BRANCH        Git branch (type: string, default: master)
  --timeout SEC          Timeout for Scalingo CLI commands (type: integer, default: 60)

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --[no-]cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl scalingo --api_token token
  dpl scalingo --username name --password pass
  dpl scalingo --api_token token --app app --region agora-fr1 --remote remote --branch branch
```

### Script

```
Usage: dpl script [options]

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

  Support for deployments to Script is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  -s --script SCRIPT      The script to execute (type: string, required: true)

Common Options:

  --run CMD               Command to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --[no-]cleanup          Skip cleaning up build artifacts before the deployment
  --help                  Get help on this command

Examples:

  dpl script --script script
  dpl script --script script --run cmd --cleanup
```

### Snap

```
Usage: dpl snap [options]

Summary:

  Snap deployment provider

Description:

  tbd

  Support for deployments to Snap is in development. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --token TOKEN       Snap API token (type: string, required: true)
  --snap STR          Path to the snap to be pushed (can be a glob) (type: string, default: **/*.snap)
  --channel CHAN      Channel into which the snap will be released (type: string, default: edge)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --[no-]cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl snap --token token
  dpl snap --token token --snap str --channel chan --run cmd --cleanup
```

### Surge

```
Usage: dpl surge [options]

Summary:

  Surge deployment provider

Description:

  tbd

  Support for deployments to Surge is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --login EMAIL       Surge login (the email address you use with Surge) (type: string, required:
                      true)
  --token TOKEN       Surge login token (can be retrieved with `surge token`) (type: string, required:
                      true)
  --domain NAME       Domain to publish to. Not required if the domain is set in the CNAME file in the
                      project folder. (type: string)
  --project PATH      Path to project directory relative to repo root (type: string, default: .)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --[no-]cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl surge --login email --token token
  dpl surge --login email --token token --domain name --project path --run cmd
```

### Testfairy

```
Usage: dpl testfairy [options]

Summary:

  Testfairy deployment provider

Description:

  tbd

  Support for deployments to Testfairy is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  --api_key KEY                       TestFairy API key (type: string, required: true)
  --app_file FILE                     Path to the app file that will be generated after the build (APK/IPA) (type:
                                      string, required: true)
  --symbols_file FILE                 Path to the symbols file (type: string)
  --testers_groups GROUPS             Tester groups to be notified about this build (type: string, e.g.: e.g.
                                      group1,group1)
  --[no-]notify                       Send an email with a changelog to your users
  --[no-]auto_update                  Automaticall upgrade all the previous installations of this app this version
  --video_quality QUALITY             Video quality settings (one of: high, medium or low (type: string, default:
                                      high)
  --screenshot_interval INTERVAL      Interval at which screenshots are taken, in seconds (type: integer, known
                                      values: 1, 2, 10)
  --max_duration DURATION             Maximum session recording length (max: 24h) (type: string, default: 10m, e.g.:
                                      20m or 1h)
  --[no-]data_only_wifi               Send video and recorded metrics only when connected to a wifi network.
  --[no-]record_on_background         Collect data while the app is on background.
  --[no-]video                        Video recording settings (default: true)
  --metrics METRICS                   Comma_separated list of metrics to record (type: string, see:
                                      http://docs.testfairy.com/Upload_API.html)
  --[no-]icon_watermark               Add a small watermark to the app icon
  --advanced_options OPTS             Comma_separated list of advanced options (type: string, e.g.: option1,option2)

Common Options:

  --run CMD                           Command to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --[no-]cleanup                      Skip cleaning up build artifacts before the deployment
  --help                              Get help on this command

Examples:

  dpl testfairy --api_key key --app_file file
  dpl testfairy --api_key key --app_file file --symbols_file file --testers_groups groups --notify
```

### Transifex

```
Usage: dpl transifex [options]

Summary:

  Transifex deployment provider

Description:

  tbd

  Support for deployments to Transifex is in alpha. Please see here: https://github.com/travis-ci/dpl/#maturity-levels

Options:

  Either api_token, or username and password are required.

  --api_token TOKEN      Transifex API token (type: string)
  --username NAME        Transifex username (type: string)
  --password PASS        Transifex password (type: string)
  --hostname NAME        Transifex hostname (type: string, default: www.transifex.com)
  --cli_version VER      CLI version to install (type: string, default: >=0.11)

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --[no-]cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl transifex --api_token token
  dpl transifex --username name --password pass
  dpl transifex --api_token token --hostname name --cli_version ver --run cmd --cleanup
```

## Contributing to Dpl

### Table of Contents

* [Resources](#resources)
* [Navigating the Codebase](#navigating-the-codebase)
* [Lifecycle of the Deployment Process](#lifecycle-of-the-deployment-process)
* [Deployment Tooling](#deployment-tooling)
* [Runtime Dependencies](#runtime-dependencies)
* [Unit Tests](#unit-tests)
* [Runtime Dependency Installation Tests](#runtime-dependency-installation-tests)
* [Integration Tests](#integration-tests)
* [Testing Dpl Branches or Forks on Travis CI](#testing-dpl-branches-or-forks-on-travis-ci)
* [Code Conventions](#code-conventions)
* [Naming Conventions](#naming-conventions)
* [Updating the README](#updating-the-readme)

Dpl is a central component in Travis CI, and has been around for a long time.

This library always has been a community effort first. There probably is not a
single person in the world who is very familiar with all deployment providers
supported by Dpl.

*Thank you all for this!*

This document is for you if you are looking to contribute to dpl, be it by
adding a new deployment provider, fixing a bug, or adding a new feature.

Dpl has a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all
interactions with the project.

Dpl is written in Ruby, and we assume that you familiarize yourself with our
documentation as much as needed.

### Resources

Hopefully helpful resources are:

* This [document](CONTRIBUTING.md)
* The [dpl README](README.md)
* The [dpl API docs](https://www.rubydoc.info/github/travis-ci/dpl) on rubydocs.info
* The [cl README](https://github.com/svenfuchs/cl/blob/master/README.md)

### Navigating the Codebase

All provider specific classes live in [dpl/providers](lib/dpl/providers).
These represent the CLI commands that are executed when the command line
exectuable `dpl` is run with a given provider name as the first argument.

Each provider is a subclass of `Dpl::Provider`, which is defined in
[dpl/provider.rb](lib/dpl/provider.rb). The provider base class itself
subclasses from `Cl::Cmd`, so it represents an executable sub command of the
main command `dpl`.

For instance, the command `dpl s3 --bucket bucket` instantiates and runs the
provider class [S3](lib/dpl/providers/s3.rb).

The class `Cl::Cmd` contributes the command line options parser, and its
class level DSL. Please see the [cl README](https://github.com/svenfuchs/cl/blob/master/README.md)
for this DSL, and the [S3 provider](/lib/dpl/provider/s3.rb)
for an example how dpl uses it.

The class `Dpl::Provider` adds, amongst other things, the order of stages
(methods) that make up the deployment process:

* `init`
* `install`
* `login`
* `setup`
* `validate`
* `prepare`
* `deploy`
* `finish`

Implementors of concrete provider classes may or may not choose to implement
any of these instance methods according to their needs, and semantics of their
tooling and service providers. Please refer to [Dpl::Provider](/lib/dpl/provider.rb)
for details.

The DSL that is used to declare features, dependencies, environment integration
etc. on the concrete provider classes is defined in the module
`Dpl::Provider::DSL`, in [dpl/provider/dsl](/lib/dpl/provider/dsl.rb).

Also of interest is [Dpl::Ctx::Bash](/lib/dpl/ctx/bash.rb),
the Bash execution context, that runs shell commands, installs dependencies
etc. (while the `Test` context class is used for testing in order to keep your
development machine clean and safe when you run tests locally).

```
lib
└── dpl
    ├── assets                # Stores larger shell scripts
    ├── ctx
    │   ├── bash.rb           # Bash execution context
    │   └── test.rb           # Test execution context
    ├── provider.rb           # Base class for all providers
    ├── provider
    │   ├── dsl.rb            # DSL for defining providers
    │   └── example.rb        # Generating example commands for help output
    └── providers
        ├── anynines.rb       # Concrete providers
        ├── atlas.rb
        ├── azure_webapps.rb
        ├── bintray.rb
        ├── bitballoon.rb
        └── ⋮
```

### Lifecycle of the Deployment Process

When a provider class is instantiated and run it will go through a number
of stages that make up the deployment process.

These are documented in [dpl/provider.rb](/lib/dpl/provider.rb).
If you are adding a new deployment provider please familiarize youself with
this lifecycle.

Feel free to pick and interpret these stages according to the needs and
semantics of the service provider you are adding. By no means do all of these
stages have to be filled in or implmented. The `Provider` base class checks for
these methods, and runs them, if present, so that implementors can choose
semantically fitting names for their providers.

### Deployment Tooling

If you are adding a new deployment provider please choose the tooling you are
going to use carefully.

Dpl is a long lived library, and it has outlived many tools that once were
supported, and no longer are. Thus tooling stability is a major concern for
this project.

Ideally use official CLI tooling supported by the company who's service
provider you are about to add. Often, such CLI tools can be installed via
standard package managers, or manually downloaded using `curl` and installed
with a few simple Bash commands.

Such CLI tooling is preferrable over Ruby gem runtime dependencies as they can
be executed in a child process, and won't introduce any dependency resolution
problems later on.

If no such CLI is available, or it does not look well supported, and your
provider implementation needs to talk to an external HTTP API then please consider
using [Net::HTTP](https://ruby-doc.org/stdlib-2.6.3/libdoc/net/http/rdoc/Net/HTTP.html)
from Ruby's standard library.

If you absolutely have to rely on a runtime Ruby gem dependency, such as a
provider client implementation, please only do so if the gem is supported by
the respective company officially. We may choose to reject including runtime
dependencies that do not look stable or widely supported.

### Runtime Dependencies

Runtime dependencies can be declared on the provider class using the
[DSL](lib/dpl/provider/dsl.rb).

In the case of APT, NPM, and Pip dependencies these will be installed via
shell commands at the beginning of the deployment process.

Ruby gem dependencies will be installed using Bundler's [inline API](https://github.com/bundler/bundler/blob/master/lib/bundler/inline.rb),
at the beginning of the deployment process, so they are available in the same
Ruby process from then on.

### Unit Tests

`Dpl` uses [RSpec](https://github.com/rspec) for tests. The specs reside in
`spec`, and each provider class has a corresponding file
`spec/dpl/providers/*_spec.rb` to hold tests.

Provider tests should be implemented on an input/output acceptance level, as
much as possible.

They use a [Ctx::Test](blob/masterlib/dpl/ctx/test.rb) execution context in
order to avoid running actual shell commands, or actually installing
dependencies at test time. There are custom [RSpec matchers](spec/support/matchers)
in place that help with making assertions against this execution context.

If your provider has to talk to an external HTTP API then ideally use
[Webmock](https://github.com/bblimke/webmock) to stub external requests. If by
any means possible try to avoid mocking or stubbing Ruby client classes (this
is not always possible, but should be considered).

#### Running Unit Tests Locally

You can run the unit test suite locally as follows:

```
bundle install
bundle exec rspec
```

In order to execute tests only for a certain provider you can run:

```
bundle exec rspec spec/dpl/providers/[provider]_spec.rb
```

In order to execute a single test or group of tests add a line number like so:

```
bundle exec rspec spec/dpl/providers/[provider]_spec.rb:25
```

These tests can be run safely on any development machine, anywhere.

### Runtime Dependency Installation Tests

We additionally run tests that exercise runtime dependency installation on
Travis CI.

These live in [.travis/test_install.rb](.travis/test_install.rb). It is not
advisable to run these tests outside of an ephemeral VM or container that can
be safely discarded, as they are going to leave various artifacts around.

### Integration Tests

In order to ensure proper integration with the service providers supported
we also periodically run a test suite that exercises actual deployments to
these providers.

These tests live in [.travis/providers](/.travis/providers), and the are
triggered using the script [trigger](/.travis/trigger).

An integration test consists of:

* A setup script that creates an application (or artifact) to deploy (or
  upload).
* A YAML config snippet that configures and triggers the deployment as part of
  a build on Travis CI.
* A test script that tests if the deployment was successful.

For example:

* [github-pages/prepare](/.travis/providers/github-pages/prepare)
  creates a minimal Git repository that serves an `index.html` on GitHub Pages in a temporary directory.
* [github-pages/travis.yml](/.travis/providers/github-pages/travis.yml)
  configures the build to use Dpl 2.0 to deploy this repository to GitHub Pages.
* [github-pages/test](/.travis/providers/github-pages/test)
  tests if the deployment was successful.

The tests can be run on Travis CI individually, or combined, by triggering a
build via our API, using the script [.travis/trigger](/.travis/trigger).
This takes a provider name as an argument, and requires a Travis CI API token.

For example, this triggers a build that executes the GitHub Pages test on
Travis CI:

```
.travis/trigger github-pages --token [token]
```

The token can also be set as an environment variable:

```
export TRAVIS_API_TOKEN=[token]
.travis/trigger github-pages
```

The `trigger` script accepts multiple provider names as arguments. If no
arguments are given then tests for all providers will be run.

#### Integration Test Configuration

In the build config YAML snippet make sure to use the branch of your fork for the
deployment tooling, and allow the deployment to run on your branch:

```yaml
deploy:
  - provider: [name]
    edge:
      source: [your-login]/dpl
      branch: [your-branch]
    on:
      branch: [your-branch]
```

Ideally use credentials for an isolated account on the service you are deploying to.
This is generally good practice, and way you can hand things off to someone else.

In order to get things working encrypt the credentials against your fork, and
add them to the build config YAML snippet. If you are in the root directory
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

```yaml
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

Whatever minimal deployment you can get working is be a great contribution.
Even if for some reason it proves hard to test the deployment in an automated
fashion, but you have a successful deployment that can be verified manually,
please still open a pull request, and talk to us. Any test is better than no
test.

### Testing Dpl Branches or Forks on Travis CI

It is possible to test a new deployment provider or new functionality of dpl on
Travis CI. In order to do so, add proper configuraiton on the `edge` key to
your `.travis.yml` like so:

```yaml
deploy:
  provider: [name]
  edge:
    source: [github-handle]/dpl
    branch: [branch]
  on:
    branch: TEST_BRANCH # or all_branches: true
  ⋮ # rest of your provider's configuration
```

This builds the `dpl` gem on the Travis CI build environment from your
repository, on the given branch. Then it installs the gem built from this code
base, and uses it to run your deployment.

When submitting a pull request, please be sure to run at least one deployment
with the new configuration, and provide a link to the build in your pull
request.

### Code Conventions

Dpl does not follow any strict code styleguide.

Please take a look around other providers, and try to follow a similar code
style to what you find.

Try to use the [DSL](/lib/dpl/provider/dsl.rb) as much
as possible.  It keeps the code declarative and readable, so that people not
familiar with Ruby or programming in general can still follow it, and make
sense of it.

If you find yourself trying to achieve something that should be, but is not
supported by the DSL please [open an issue](https://github.com/travis-ci/dpl/issues/new)
about it.

If you are rather unfamiliar with Ruby, and have trouble following our code
style then please submit your pull request anyway, or get in touch, so we can
help.

### Naming Conventions

Dpl uses constant names following Ruby naming conventions. I.e. constant
names use `CamelCase`, and they live in files named in `snake_case.rb`.

If you pick such names for a new provider please try to follow these
conventions.

Real world service provider or company names do not always translate to such
conventional Ruby names one-to-one. That is ok, they don't have to. These Ruby
constant names are representations of real world service and company names in
Ruby code.

Other Ruby libraries often (not always) follow a similar thinking. E.g.
even though Amazon Web Services brand name is `AWS` the module name
they chose in their [aws-sdk](https://github.com/aws/aws-sdk-ruby) is
`Aws`, not `AWS`.

### Updating the README

The [README](/README.md) is generated from a
[template](/lib/dpl/assets/dpl/README.erb.md).

In order to update the README please edit the template, and run the command:

```
bin/readme > README.md
```


## Old Issues

If an issue has been left open and untouched for 90 days or more, we
automatically close them. We do this to ensure that new issues are more easily
noticeable, and that old issues that have been resolved or are no longer
relevant are closed. You can read more about this [here](https://blog.travis-ci.com/2018-03-09-closing-old-issues).

## Code of Conduct

Please see [our code of conduct](CODE_OF_CONDUCT.md) for how to interact with
this project and its community.

## License

Dpl is licensed under the [MIT License](https://github.com/travis-ci/dpl/blob/master/LICENSE).

## Credits

This tool would not exist without your help.

A huge thank you goes out to all of our current and past [contributors](https://github.com/travis-ci/dpl/graphs/contributors):

5c077yP, A.J. May, A92hm, Aakriti Gupta, Aaron Hill, Aaron1011, Abdón Rodríguez Davila, Abdón Rodríguez Davila, Adam King, Adam Mcgrath
Adrian Moreno, Ahmad Nassri, Ahmed Refaey, Ainun Nazieb, Albertin Loic, Alexander Springer, Alexey Kotlyarov, Ali Hajimirza, Amos Wenger, Anders Olsen Sandvik
Andrey Lushchick, Andy Vanbutsele, Angelo Livanos, Anne-Julia Seitz, Antoine Savignac, Anton Babenko, Anton Ilin, Arnold Daniels, Ashen Gunaratne, Axel Fontaine
Baptiste Courtois, Ben Hale, Benjamin Guttmann, Bob, Bob Zoller, Brad Gignac, Brandon Burton, Brandon LeBlanc, Brian Hou, Cameron White
Carla, Chad Engler, Chathan Driehuys, Christian Elsen, Christian Rackerseder, Clay Reimann, Cryptophobia, Damien Mathieu, Dan Buch, Dan Powell
Daniel X Moore, David F. Severski, Denis Cornehl, Dennis Koot, Devin J. Pohly, Dominic Jodoin, Dwayne Forde, Eric Peterson, Erik Dalén, Esteban Santiesteban
Fabio Napoleoni, Felix Rieseberg, Filip Š, Flamur Gogolli, Gabriel Saldana, George Brighton, Gil, Gil Megidish, Gil Tselenchuk, Hao Luo
Hauke Stange, Henrik Hodne, Hiro Asari, IMANAKA, Kouta, Ivan Evtuhovich, Ivan Kusalic, Ivan Pozdeev, Jacob Burkhart, Jake Hewitt, Jakub Holy
James Adam, James Awesome, James Parker, Janderson, Jannis Leidel, Jeffrey Yasskin, Jeremy Frasier, Joe Damato, Joep van Delft, Johannes Würbach
Johannes Würbach, Johnny Dobbins, Jon Benson, Jon Rowe, Jon-Erik Schneiderhan, Jonatan Männchen, Jonathan Stites, Jonathan Sundqvist, Josh Kalderimis, Jouni Kaplas
Julia S.Simon, Julio Capote, Karim Fateem, Ke Zhu, Konstantin Haase, Kouta Imanaka, Kristofer Svardstal, Kyle Fazzari, Kyle VanderBeek, Lorenz Leutgeb
Lorne Currie, Louis Lagrange, Louis St-Amour, Loïc Mahieu, Luke Yeager, Maciej Skierkowski, Mariana Lenetis and Zachary Gershman, Marius Gripsgard, Mark Pundsack, Marwan Rabbâa
María de Antón, Mathias Meyer, Mathias Rangel Wulff, Mathias San Miguel, Matt Hernandez, Matt Knox, Matt Travi, Matthew Knox, Maxime Brugidou, Meir Gottlieb
Michael Bleigh, Michael Dunn, Michael Friis, Michel Boudreau, Mike Bryant, Nat Welch, Nicholas Bruning, Nick Mohoric, Nico Lindemann, Nigel Ramsay
Ole Michaelis, Omer Katz, Paul Beaudoin, Paul Nikitochkin, Peter, Peter Georgantas, Peter Newman, Philipp Hansch, Piotr Sarnacki, Rail Aliiev
Randall A. Gordon, Robert Gogolok, Rokas Brazdžionis, Romuald Bulyshko, Ryn Daniels, SAULEAU Sven, Samir Talwar, Samuel Wright, Sandor Zeestraten, Scot Spinner
Sebastien Estienne, Sergei Chertkov, Simon, Solly, Sorin Sbarnea, Soulou, Stefan Kolb, Steffen Kötte, Steven Berlanga, Sven Fuchs
Sviatoslav Sydorenko, Tim Ysewyn, Travis CI, Troels Thomsen, Tyler Cross, Uriah Levy, Vincent Jacques, Vojtech Vondra, Vojtěch Vondra, Wael M. Nasreddine
Wim Looman, Xavier Krantz, Zane Williamson, adinata, awesomescot, capotej, carlad, cleem, emdantrim, eyalbe4
fgogolli, johanneswuerbach, jorgecasar, joshua-anderson, jung_b@localhost, konrad-c, mariadeanton, marscher, mayeut, ryanj
shunyi, step76, testfairy, yeonhoyoon, Étienne Michon
