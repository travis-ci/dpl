# Dpl [![Build Status](https://travis-ci.com/travis-ci/dpl.svg?branch=master)](https://travis-ci.com/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.svg)](https://codeclimate.com/github/travis-ci/dpl) [![Coverage Status](https://coveralls.io/repos/travis-ci/dpl/badge.svg?branch=master&service=github&cache=2019-08-09_17:00)](https://coveralls.io/github/travis-ci/dpl?branch=master) [![Gem Version](https://img.shields.io/gem/v/dpl)](http://rubygems.org/gems/dpl) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/travis-ci/dpl)

This version of the README documents dpl v2, the next major version of dpl.
The README for dpl v1, the version that is currently used in production on
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

This version of dpl is currently released as an `alpha` preview release. In
order to install it, add the `--pre` flag:

```
gem install dpl --pre
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
* `stable` - the provider has been in beta for at least a month, and there are no open issues that qualify as critical (such as deployments failing, documented functionality broken, etc)

## Supported Providers

Dpl supports the following providers:

  * [Anynines](#anynines)
  * [AWS CloudFormation](#aws-cloudformation)
  * [AWS Code Deploy](#aws-code-deploy)
  * [AWS ECR](#aws-ecr)
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
  * [Convox](#convox)
  * [Datica](#datica)
  * [Engineyard](#engineyard)
  * [Firebase](#firebase)
  * [Flynn](#flynn)
  * [Git (push)](#git-push)
  * [GitHub Pages](#github-pages)
  * [GitHub Pages (API)](#github-pages-api)
  * [GitHub Releases](#github-releases)
  * [Gleis](#gleis)
  * [Google App Engine](#google-app-engine)
  * [Google Cloud Store](#google-cloud-store)
  * [Hackage](#hackage)
  * [Hephy](#hephy)
  * [Heroku API](#heroku-api)
  * [Heroku Git](#heroku-git)
  * [Launchpad](#launchpad)
  * [Netlify](#netlify)
  * [npm](#npm)
  * [nuget](#nuget)
  * [OpenShift](#openshift)
  * [Packagecloud](#packagecloud)
  * [Puppet Forge](#puppet-forge)
  * [PyPI](#pypi)
  * [Rubygems](#rubygems)
  * [Scalingo](#scalingo)
  * [Script](#script)
  * [Snap](#snap)
  * [Surge](#surge)
  * [TestFairy](#testfairy)
  * [Transifex](#transifex)


### Anynines

Support for deployments to Anynines is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl anynines [options]

Summary:

  Anynines deployment provider

Description:

  tbd

Options:

  --username USER         anynines username (type: string, required)
  --password PASS         anynines password (type: string, required)
  --organization ORG      anynines organization (type: string, required)
  --space SPACE           anynines space (type: string, required)
  --app_name APP          Application name (type: string)
  --buildpack PACK        Buildpack name or Git URL (type: string)
  --manifest FILE         Path to the manifest (type: string)

Common Options:

  --cleanup               Clean up build artifacts from the Git working directory before the deployment
  --run CMD               Commands to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --help                  Get help on this command

Examples:

  dpl anynines --username user --password pass --organization org --space space
  dpl anynines --username user --password pass --organization org --space space --app_name app
```

Options can be given via env vars if prefixed with `ANYNINES_`. E.g. the option `--password` can be
given as `ANYNINES_PASSWORD=<password>`.

### AWS CloudFormation



```
Usage: dpl cloudformation [options]

Summary:

  AWS CloudFormation deployment provider

Description:

  tbd

Options:

  --access_key_id ID           AWS Access Key ID (type: string, required)
  --secret_access_key KEY      AWS Secret Key (type: string, required)
  --region REGION              AWS Region to deploy to (type: string, default: us-east-1)
  --template STR               CloudFormation template file (type: string, required, note: can be either a
                               local path or an S3 URL)
  --stack_name NAME            CloudFormation Stack Name. (type: string, required)
  --stack_name_prefix STR      CloudFormation Stack Name Prefix. (type: string)
  --[no-]promote               Deploy changes (default: true, note: otherwise a change set is created)
  --role_arn ARN               AWS Role ARN (type: string)
  --sts_assume_role ARN        AWS Role ARN for cross account deployments (assumed by travis using given AWS
                               credentials). (type: string)
  --capabilities STR           CloudFormation allowed capabilities (type: array (string, can be given multiple
                               times), known values: CAPABILITY_IAM, CAPABILITY_NAMED_IAM,
                               CAPABILITY_AUTO_EXPAND, see:
                               https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html)
  --[no-]wait                  Wait for CloutFormation to finish the stack creation and update (default: true)
  --wait_timeout SEC           How many seconds to wait for stack creation and update. (type: integer, default:
                               3600)
  --create_timeout SEC         How many seconds to wait before the stack status becomes CREATE_FAILED (type:
                               integer, default: 3600, note: valid only when creating a stack)
  --parameters STR             key=value pairs or ENV var names (type: array (string, can be given multiple
                               times))
  --output_file PATH           Path to output file to store CloudFormation outputs to (type: string)

Common Options:

  --cleanup                    Clean up build artifacts from the Git working directory before the deployment
  --run CMD                    Commands to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --help                       Get help on this command

Examples:

  dpl cloudformation --access_key_id id --secret_access_key key --template str --stack_name name
  dpl cloudformation --access_key_id id --secret_access_key key --template str --stack_name name --region region
```

Options can be given via env vars if prefixed with `[AWS_|CLOUDFORMATION_]`. E.g. the option
`--access_key_id` can be given as `AWS_ACCESS_KEY_ID=<access_key_id>` or
`CLOUDFORMATION_ACCESS_KEY_ID=<access_key_id>`.

### AWS Code Deploy



```
Usage: dpl codedeploy [options]

Summary:

  AWS Code Deploy deployment provider

Description:

  tbd

Options:

  --access_key_id ID              AWS access key (type: string, required)
  --secret_access_key KEY         AWS secret access key (type: string, required)
  --application NAME              CodeDeploy application name (type: string, required)
  --deployment_group GROUP        CodeDeploy deployment group name (type: string)
  --revision_type TYPE            CodeDeploy revision type (type: string, known values: s3, github, downcases)
  --commit_id SHA                 Commit ID in case of GitHub (type: string)
  --repository NAME               Repository name in case of GitHub (type: string)
  --bucket NAME                   S3 bucket in case of S3 (type: string)
  --region REGION                 AWS availability zone (type: string, default: us-east-1)
  --file_exists_behavior STR      How to handle files that already exist in a deployment target location (type:
                                  string, default: disallow, known values: disallow, overwrite, retain)
  --[no-]wait_until_deployed      Wait until the deployment has finished
  --bundle_type TYPE              Bundle type of the revision (type: string)
  --key KEY                       S3 bucket key of the revision (type: string)
  --description DESCR             Description of the revision (type: string)
  --endpoint ENDPOINT             S3 endpoint url (type: string)

Common Options:

  --cleanup                       Clean up build artifacts from the Git working directory before the deployment
  --run CMD                       Commands to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --help                          Get help on this command

Examples:

  dpl codedeploy --access_key_id id --secret_access_key key --application name
  dpl codedeploy --access_key_id id --secret_access_key key --application name --deployment_group group --revision_type s3
```

Options can be given via env vars if prefixed with `[AWS_|CODEDEPLOY_]`. E.g. the option
`--access_key_id` can be given as `AWS_ACCESS_KEY_ID=<access_key_id>` or
`CODEDEPLOY_ACCESS_KEY_ID=<access_key_id>`.

The following variable are availabe for interpolation on `description`:

  `application`, `bucket`, `bundle_type`, `commit_id`, `deployment_group`, `endpoint`, `file_exists_behavior`, `git_author_email`, `git_author_name`, `git_branch`, `git_commit_author`, `git_commit_msg`, `git_sha`, `git_tag`, `key`, `region`, `repository`, `revision_type`, `build_number`


### AWS ECR

Support for deployments to AWS ECR is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl ecr [options]

Summary:

  AWS ECR deployment provider

Description:

  tbd

Options:

  --access_key_id ID           AWS access key (type: string, required)
  --secret_access_key KEY      AWS secret access key (type: string, required)
  --account_id ID              AWS Account ID (type: string, note: Required if the repository is owned by a
                               different account than the IAM user)
  --source SOURCE              Image to push (type: string, required, note: can be the id or the name and
                               optional tag (e.g. mysql:5.6))
  --target TARGET              Comma separated list of partial repository names to push to (type: string,
                               required)
  --region REGION              Comma separated list of regions to push to (type: string, default: us-east-1)

Common Options:

  --cleanup                    Clean up build artifacts from the Git working directory before the deployment
  --run CMD                    Commands to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --help                       Get help on this command

Examples:

  dpl ecr --access_key_id id --secret_access_key key --source source --target target
  dpl ecr --access_key_id id --secret_access_key key --source source --target target --account_id id
```

Options can be given via env vars if prefixed with `AWS_`. E.g. the option `--access_key_id` can be
given as `AWS_ACCESS_KEY_ID=<access_key_id>`.

### AWS Elastic Beanstalk



```
Usage: dpl elasticbeanstalk [options]

Summary:

  AWS Elastic Beanstalk deployment provider

Description:

  Deploy to AWS Elastic Beanstalk: https://aws.amazon.com/elasticbeanstalk/

  This provider:

  * Creates a zip file (or uses one you provide)
  * Uploads it to your EB application
  * Optionally deploys to a specific EB environment
  * Optionally waits until the deployment finishes

Options:

  --access_key_id ID                     AWS Access Key ID (type: string, required)
  --secret_access_key KEY                AWS Secret Key (type: string, required)
  --region REGION                        AWS Region the Elastic Beanstalk app is running in (type: string, default:
                                         us-east-1)
  --app NAME                             Elastic Beanstalk application name (type: string, default: repo name)
  --env NAME                             Elastic Beanstalk environment name to be updated. (type: string)
  --bucket NAME                          Bucket name to upload app to (type: string, required, alias: bucket_name)
  --bucket_path PATH                     Location within Bucket to upload app to (type: string)
  --description DESC                     Description for the application version (type: string)
  --label LABEL                          Label for the application version (type: string)
  --zip_file PATH                        The zip file that you want to deploy. If not given, a zipfile will be created
                                         from the current directory, honoring .ebignore and .gitignore. (type: string)
  --[no-]wait_until_deployed             Wait until the deployment has finished (requires: env)
  --wait_until_deployed_timeout SEC      How many seconds to wait for Elastic Beanstalk deployment update. (type:
                                         integer, default: 600)

Common Options:

  --cleanup                              Clean up build artifacts from the Git working directory before the deployment
  --run CMD                              Commands to execute after the deployment finished successfully (type: array
                                         (string, can be given multiple times))
  --help                                 Get help on this command

Examples:

  dpl elasticbeanstalk --access_key_id id --secret_access_key key --bucket name
  dpl elasticbeanstalk --access_key_id id --secret_access_key key --bucket name --region region --app name
```

Options can be given via env vars if prefixed with `[AWS_|ELASTIC_BEANSTALK_]`. E.g. the option
`--access_key_id` can be given as `AWS_ACCESS_KEY_ID=<access_key_id>` or
`ELASTIC_BEANSTALK_ACCESS_KEY_ID=<access_key_id>`.

### AWS Lambda



```
Usage: dpl lambda [options]

Summary:

  AWS Lambda deployment provider

Description:

  tbd

Options:

  --access_key_id ID            AWS access key id (type: string, required)
  --secret_access_key KEY       AWS secret key (type: string, required)
  --region REGION               AWS region the Lambda function is running in (type: string, default: us-east-1)
  --function_name FUNC          Name of the Lambda being created or updated (type: string, required)
  --role ROLE                   ARN of the IAM role to assign to the Lambda function (type: string, note:
                                required when creating a new function)
  --handler_name NAME           Function the Lambda calls to begin execution. (type: string, note: required when
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
  --runtime NAME                Lambda runtime to use (type: string, default: nodejs10.x, known values:
                                nodejs14.x, nodejs12.x, nodejs10.x, python3.8, python3.7, python3.6, python2.7,
                                ruby2.7, ruby2.5, java11, java8, go1.x, dotnetcore2.1, note: required when
                                creating a new function)
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

  --cleanup                     Clean up build artifacts from the Git working directory before the deployment
  --run CMD                     Commands to execute after the deployment finished successfully (type: array
                                (string, can be given multiple times))
  --help                        Get help on this command

Examples:

  dpl lambda --access_key_id id --secret_access_key key --function_name func
  dpl lambda --access_key_id id --secret_access_key key --function_name func --region region --role role
```

Options can be given via env vars if prefixed with `[AWS_|LAMBDA_]`. E.g. the option
`--access_key_id` can be given as `AWS_ACCESS_KEY_ID=<access_key_id>` or
`LAMBDA_ACCESS_KEY_ID=<access_key_id>`.

The following variable are availabe for interpolation on `description`:

  `dead_letter_arn`, `function_name`, `git_author_email`, `git_author_name`, `git_branch`, `git_commit_author`, `git_commit_msg`, `git_sha`, `git_tag`, `handler_name`, `kms_key_arn`, `memory_size`, `module_name`, `region`, `role`, `runtime`, `timeout`, `tracing_mode`, `zip`


### AWS OpsWorks



```
Usage: dpl opsworks [options]

Summary:

  AWS OpsWorks deployment provider

Description:

  tbd

Options:

  --access_key_id ID              AWS access key id (type: string, required)
  --secret_access_key KEY         AWS secret key (type: string, required)
  --app_id APP                    The app id (type: string, required)
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

  --cleanup                       Clean up build artifacts from the Git working directory before the deployment
  --run CMD                       Commands to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --help                          Get help on this command

Examples:

  dpl opsworks --access_key_id id --secret_access_key key --app_id app
  dpl opsworks --access_key_id id --secret_access_key key --app_id app --region region --instance_ids id
```

Options can be given via env vars if prefixed with `[AWS_|OPSWORKS_]`. E.g. the option
`--access_key_id` can be given as `AWS_ACCESS_KEY_ID=<access_key_id>` or
`OPSWORKS_ACCESS_KEY_ID=<access_key_id>`.

### AWS S3



```
Usage: dpl s3 [options]

Summary:

  AWS S3 deployment provider

Description:

  tbd

Options:

  --access_key_id ID                  AWS access key id (type: string, required)
  --secret_access_key KEY             AWS secret key (type: string, required)
  --bucket BUCKET                     S3 bucket (type: string, required)
  --region REGION                     S3 region (type: string, default: us-east-1)
  --endpoint URL                      S3 endpoint (type: string)
  --upload_dir DIR                    S3 directory to upload to (type: string)
  --local_dir DIR                     Local directory to upload from (type: string, default: ., e.g.: ~/travis/build
                                      (absolute path) or ./build (relative path))
  --glob GLOB                         Files to upload (type: string, default: **/*)
  --[no-]dot_match                    Upload hidden files starting with a dot
  --acl ACL                           Access control for the uploaded objects (type: string, default: private, known
                                      values: private, public_read, public_read_write, authenticated_read,
                                      bucket_owner_read, bucket_owner_full_control)
  --[no-]detect_encoding              HTTP header Content-Encoding for files compressed with gzip and compress
                                      utilities
  --cache_control STR                 HTTP header Cache-Control to suggest that the browser cache the file (type:
                                      array (string, can be given multiple times), default: no-cache, known values:
                                      /^no-cache.*/, /^no-store.*/, /^max-age=\d+.*/, /^s-maxage=\d+.*/,
                                      /^no-transform/, /^public/, /^private/, note: accepts mapping values to globs)
  --expires DATE                      Date and time that the cached object expires (type: array (string, can be given
                                      multiple times), format: /^"?\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .+"?.*$/, note:
                                      accepts mapping values to globs)
  --default_text_charset CHARSET      Default character set to append to the content-type of text files (type: string)
  --storage_class CLASS               S3 storage class to upload as (type: string, default: STANDARD, known values:
                                      STANDARD, STANDARD_IA, REDUCED_REDUNDANCY)
  --[no-]server_side_encryption       Use S3 Server Side Encryption (SSE-AES256)
  --index_document_suffix SUFFIX      Index document suffix of a S3 website (type: string)
  --[no-]overwrite                    Whether or not to overwrite existing files (default: true)
  --[no-]force_path_style             Whether to force keeping the bucket name on the path
  --max_threads NUM                   The number of threads to use for S3 file uploads (type: integer, default: 5,
                                      max: 15)
  --[no-]verbose                      Be verbose about uploading files

Common Options:

  --cleanup                           Clean up build artifacts from the Git working directory before the deployment
  --run CMD                           Commands to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --help                              Get help on this command

Examples:

  dpl s3 --access_key_id id --secret_access_key key --bucket bucket
  dpl s3 --access_key_id id --secret_access_key key --bucket bucket --region region --endpoint url
```

Options can be given via env vars if prefixed with `[AWS_|S3_]`. E.g. the option `--access_key_id`
can be given as `AWS_ACCESS_KEY_ID=<access_key_id>` or `S3_ACCESS_KEY_ID=<access_key_id>`.

### Azure Web Apps

Support for deployments to Azure Web Apps is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl azure_web_apps [options]

Summary:

  Azure Web Apps deployment provider

Description:

  tbd

Options:

  --username NAME      Web App Deployment Username (type: string, required)
  --password PASS      Web App Deployment Password (type: string, required)
  --site SITE          Web App name (e.g. myapp in myapp.azurewebsites.net) (type: string, required)
  --slot SLOT          Slot name (if your app uses staging deployment) (type: string)
  --[no-]verbose       Print deployment output from Azure. Warning: If authentication fails, Git prints
                       credentials in clear text. Correct credentials remain hidden.

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl azure_web_apps --username name --password pass --site site
  dpl azure_web_apps --username name --password pass --site site --slot slot --verbose
```

Options can be given via env vars if prefixed with `AZURE_WA_`. E.g. the option `--password` can be
given as `AZURE_WA_PASSWORD=<password>`.

### Bintray



```
Usage: dpl bintray [options]

Summary:

  Bintray deployment provider

Description:

  tbd

Options:

  --user USER              Bintray user (type: string, required)
  --key KEY                Bintray API key (type: string, required)
  --file FILE              Path to a descriptor file for the Bintray upload (type: string, required)
  --passphrase PHRASE      Passphrase as configured on Bintray (if GPG signing is used) (type: string)

Common Options:

  --cleanup                Clean up build artifacts from the Git working directory before the deployment
  --run CMD                Commands to execute after the deployment finished successfully (type: array
                           (string, can be given multiple times))
  --help                   Get help on this command

Examples:

  dpl bintray --user user --key key --file file
  dpl bintray --user user --key key --file file --passphrase phrase --cleanup
```

Options can be given via env vars if prefixed with `BINTRAY_`. E.g. the option `--key` can be given
as `BINTRAY_KEY=<key>`.

### Bluemix Cloud Foundry



```
Usage: dpl bluemixcloudfoundry [options]

Summary:

  Bluemix Cloud Foundry deployment provider

Description:

  tbd

Options:

  --username USER                 Bluemix username (type: string, required)
  --password PASS                 Bluemix password (type: string, required)
  --organization ORG              Bluemix organization (type: string, required)
  --space SPACE                   Bluemix space (type: string, required)
  --region REGION                 Bluemix region (type: string, default: ng, known values: ng, eu-gb, eu-de,
                                  au-syd)
  --api URL                       Bluemix api URL (type: string)
  --app_name APP                  Application name (type: string)
  --buildpack PACK                Buildpack name or Git URL (type: string)
  --manifest FILE                 Path to the manifest (type: string)
  --[no-]skip_ssl_validation      Skip SSL validation

Common Options:

  --cleanup                       Clean up build artifacts from the Git working directory before the deployment
  --run CMD                       Commands to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --help                          Get help on this command

Examples:

  dpl bluemixcloudfoundry --username user --password pass --organization org --space space
  dpl bluemixcloudfoundry --username user --password pass --organization org --space space --region ng
```

Options can be given via env vars if prefixed with `CLOUDFOUNDRY_`. E.g. the option `--password` can
be given as `CLOUDFOUNDRY_PASSWORD=<password>`.

### Boxfuse

Support for deployments to Boxfuse is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl boxfuse [options]

Summary:

  Boxfuse deployment provider

Description:

  tbd

Options:

  --user USER             type: string, required
  --secret SECRET         type: string, required
  --payload PAYLOAD       type: string
  --app APP               type: string
  --version VERSION       type: string
  --env ENV               type: string
  --config_file FILE      type: string, alias: configfile (deprecated, please use config_file)
  --extra_args ARGS       type: string

Common Options:

  --cleanup               Clean up build artifacts from the Git working directory before the deployment
  --run CMD               Commands to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --help                  Get help on this command

Examples:

  dpl boxfuse --user user --secret secret
  dpl boxfuse --user user --secret secret --payload payload --app app --version version
```

Options can be given via env vars if prefixed with `BOXFUSE_`. E.g. the option `--secret` can be
given as `BOXFUSE_SECRET=<secret>`.

### Cargo



```
Usage: dpl cargo [options]

Summary:

  Cargo deployment provider

Description:

  tbd

Options:

  --token TOKEN           Cargo registry API token (type: string, required)
  --[no-]allow_dirty      Allow publishing from a dirty git working directory

Common Options:

  --cleanup               Clean up build artifacts from the Git working directory before the deployment
  --run CMD               Commands to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --help                  Get help on this command

Examples:

  dpl cargo --token token
  dpl cargo --token token --allow_dirty --cleanup --run cmd
```

Options can be given via env vars if prefixed with `CARGO_`. E.g. the option `--token` can be given
as `CARGO_TOKEN=<token>`.

### Chef Supermarket

Support for deployments to Chef Supermarket is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl chef_supermarket [options]

Summary:

  Chef Supermarket deployment provider

Description:

  tbd

Options:

  --user_id ID          Chef Supermarket user name (type: string, required)
  --name NAME           Cookbook name (type: string, alias: cookbook_name (deprecated, please use name),
                        note: defaults to the name given in metadata.json or metadata.rb)
  --category CAT        Cookbook category in Supermarket (type: string, required, alias:
                        cookbook_category (deprecated, please use category), see:
                        https://docs.getchef.com/knife_cookbook_site.html#id12)
  --client_key KEY      Client API key file name (type: string, default: client.pem)
  --dir DIR             Directory containing the cookbook (type: string, default: .)

Common Options:

  --cleanup             Clean up build artifacts from the Git working directory before the deployment
  --run CMD             Commands to execute after the deployment finished successfully (type: array
                        (string, can be given multiple times))
  --help                Get help on this command

Examples:

  dpl chef_supermarket --user_id id --category cat
  dpl chef_supermarket --user_id id --category cat --name name --client_key key --dir dir
```

Options can be given via env vars if prefixed with `CHEF_`.

### Cloud Files

Support for deployments to Cloud Files is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl cloudfiles [options]

Summary:

  Cloud Files deployment provider

Description:

  tbd

Options:

  --username USER       Rackspace username (type: string, required)
  --api_key KEY         Rackspace API key (type: string, required)
  --region REGION       Cloudfiles region (type: string, required, known values: ord, dfw, syd, iad,
                        hkg)
  --container NAME      Name of the container that files will be uploaded to (type: string, required)
  --glob GLOB           Paths to upload (type: string, default: **/*)
  --[no-]dot_match      Upload hidden files starting a dot

Common Options:

  --cleanup             Clean up build artifacts from the Git working directory before the deployment
  --run CMD             Commands to execute after the deployment finished successfully (type: array
                        (string, can be given multiple times))
  --help                Get help on this command

Examples:

  dpl cloudfiles --username user --api_key key --region ord --container name
  dpl cloudfiles --username user --api_key key --region ord --container name --glob glob
```

Options can be given via env vars if prefixed with `CLOUDFILES_`. E.g. the option `--api_key` can be
given as `CLOUDFILES_API_KEY=<api_key>`.

### Cloud Foundry



```
Usage: dpl cloudfoundry [options]

Summary:

  Cloud Foundry deployment provider

Description:

  tbd

Options:

  --username USER                     Cloud Foundry username (type: string, required)
  --password PASS                     Cloud Foundry password (type: string, required)
  --organization ORG                  Cloud Foundry organization (type: string, required)
  --space SPACE                       Cloud Foundry space (type: string, required)
  --api URL                           Cloud Foundry api URL (type: string, default: https://api.run.pivotal.io)
  --app_name APP                      Application name (type: string)
  --buildpack PACK                    Buildpack name or Git URL (type: string)
  --manifest FILE                     Path to the manifest (type: string)
  --[no-]skip_ssl_validation          Skip SSL validation
  --deployment_strategy STRATEGY      Deployment strategy, either rolling or null (type: string)
  --[no-]v3                           Use the v3 API version to push the application

Common Options:

  --cleanup                           Clean up build artifacts from the Git working directory before the deployment
  --run CMD                           Commands to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --help                              Get help on this command

Examples:

  dpl cloudfoundry --username user --password pass --organization org --space space
  dpl cloudfoundry --username user --password pass --organization org --space space --api url
```

Options can be given via env vars if prefixed with `CLOUDFOUNDRY_`. E.g. the option `--password` can
be given as `CLOUDFOUNDRY_PASSWORD=<password>`.

### Cloud66

Support for deployments to Cloud66 is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl cloud66 [options]

Summary:

  Cloud66 deployment provider

Description:

  tbd

Options:

  --redeployment_hook URL      The redeployment hook URL (type: string, required)

Common Options:

  --cleanup                    Clean up build artifacts from the Git working directory before the deployment
  --run CMD                    Commands to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --help                       Get help on this command

Examples:

  dpl cloud66 --redeployment_hook url
  dpl cloud66 --redeployment_hook url --cleanup --run cmd
```

Options can be given via env vars if prefixed with `CLOUD66_`. E.g. the option `--redeployment_hook`
can be given as `CLOUD66_REDEPLOYMENT_HOOK=<redeployment_hook>`.

### Convox

Support for deployments to Convox is in **development**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl convox [options]

Summary:

  Convox deployment provider

Description:

  tbd

Options:

  --host HOST            type: string, default: console.convox.com
  --app APP              type: string, required
  --rack RACK            type: string, required
  --password PASS        type: string, required
  --install_url URL      type: string, default: https://convox.com/cli/linux/convox
  --[no-]update_cli
  --[no-]create
  --[no-]promote         default: true
  --env_names VARS       type: array (string, can be given multiple times)
  --env VARS             type: array (string, can be given multiple times)
  --env_file FILE        type: string
  --description STR      type: string
  --generation NUM       type: integer, default: 2
  --prepare CMDS         Run commands with convox cli available just before deployment (type: array
                         (string, can be given multiple times))

Common Options:

  --cleanup              Clean up build artifacts from the Git working directory before the deployment
  --run CMD              Commands to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --help                 Get help on this command

Examples:

  dpl convox --app app --rack rack --password pass
  dpl convox --app app --rack rack --password pass --host host --install_url url
```

Options can be given via env vars if prefixed with `CONVOX_`.

### Datica

Support for deployments to Datica is in **development**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl datica [options]
   or: dpl catalyze [options]

Summary:

  Datica deployment provider

Description:

  tbd

Options:

  --target TARGET      The git remote repository to deploy to (type: string, required)
  --path PATH          Path to files to deploy (type: string, default: .)

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl datica --target target
  dpl datica --target target --path path --cleanup --run cmd
```

Options can be given via env vars if prefixed with `[CATALYZE_|DATICA_]`.

### Engineyard

Support for deployments to Engineyard is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl engineyard [options]

Summary:

  Engineyard deployment provider

Description:

  tbd

Options:

  Either api_key, or email and password are required.

  --api_key KEY        Engine Yard API key (type: string, note: can be obtained at
                       https://cloud.engineyard.com/cli)
  --email EMAIL        Engine Yard account email (type: string)
  --password PASS      Engine Yard password (type: string)
  --app APP            Engine Yard application name (type: string, default: repo name)
  --env ENV            Engine Yard application environment (type: string, alias: environment)
  --migrate CMD        Engine Yard migration commands (type: string)
  --account NAME       Engine Yard account name (type: string)

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl engineyard --api_key key
  dpl engineyard --email email --password pass
  dpl engineyard --api_key key --app app --env env --migrate cmd --account name
```

Options can be given via env vars if prefixed with `[ENGINEYARD_|EY_]`. E.g. the option `--api_key`
can be given as `ENGINEYARD_API_KEY=<api_key>` or `EY_API_KEY=<api_key>`.

### Firebase



```
Usage: dpl firebase [options]

Summary:

  Firebase deployment provider

Description:

  tbd

Options:

  --token TOKEN        Firebase CI access token (generate with firebase login:ci) (type: string,
                       required)
  --project NAME       Firebase project to deploy to (defaults to the one specified in your
                       firebase.json) (type: string)
  --message MSG        Message describing this deployment. (type: string)
  --only SERVICES      Firebase services to deploy (type: string, note: can be a comma-separated list)
  --[no-]force         Whether or not to delete Cloud Functions missing from the current working
                       directory

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl firebase --token token
  dpl firebase --token token --project name --message msg --only services --force
```

Options can be given via env vars if prefixed with `FIREBASE_`. E.g. the option `--token` can be
given as `FIREBASE_TOKEN=<token>`.

### Flynn

Support for deployments to Flynn is in **development**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl flynn [options]

Summary:

  Flynn deployment provider

Description:

  Flynn provider for Dpl

Options:

  --git URL      Flynn Git remote URL (type: string, required)

Common Options:

  --cleanup      Clean up build artifacts from the Git working directory before the deployment
  --run CMD      Commands to execute after the deployment finished successfully (type: array
                 (string, can be given multiple times))
  --help         Get help on this command

Examples:

  dpl flynn --git url
  dpl flynn --git url --cleanup --run cmd
```



### Git (push)

Support for deployments to Git (push) is in **development**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl git_push [options]

Summary:

  Git (push) deployment provider

Description:

  Experimental, generic provider for updating a Git remote branch with
  changes produced by the build, and optionally opening a pull request.

Options:

  Either token, or deploy_key and name and email are required.

  --repo SLUG                    Repo slug (type: string, default: repo slug)
  --token TOKEN                  GitHub token with repo permission (type: string, alias: github_token)
  --deploy_key PATH              Path to a file containing a private deploy key with write access to the
                                 repository (type: string, see:
                                 https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys)
  --branch BRANCH                Target branch to push to (type: string, required)
  --base_branch BRANCH           Base branch to branch off initially, and (optionally) create a pull request for
                                 (type: string, default: master)
  --name NAME                    Committer name (type: string, note: defaults to the GitHub name or login
                                 associated with the GitHub token)
  --email EMAIL                  Committer email (type: string, note: defaults to the GitHub email associated
                                 with the GitHub token)
  --commit_message MSG           type: string, default: Update %{base_branch}
  --[no-]allow_empty_commit      Allow an empty commit to be created
  --[no-]force                   Whether to push --force (default: false)
  --local_dir DIR                Local directory to push (type: string, default: .)
  --[no-]pull_request            Whether to create a pull request for the given branch
  --[no-]allow_same_branch       Whether to allow pushing to the same branch as the current branch (default:
                                 false, note: setting this to true risks creating infinite build loops, use
                                 conditional builds or other mechanisms to prevent build from infinitely
                                 triggering more builds)
  --host HOST                    type: string, default: github.com
  --[no-]enterprise              Whether to use a GitHub Enterprise API style URL

Common Options:

  --cleanup                      Clean up build artifacts from the Git working directory before the deployment
  --run CMD                      Commands to execute after the deployment finished successfully (type: array
                                 (string, can be given multiple times))
  --help                         Get help on this command

Examples:

  dpl git_push --branch branch --token token
  dpl git_push --branch branch --deploy_key path --name name --email email
  dpl git_push --branch branch
  dpl git_push --branch branch --token token --repo slug --base_branch branch --commit_message msg
```

Options can be given via env vars if prefixed with `[GITHUB_|GIT_]`. E.g. the option `--token` can
be given as `GITHUB_TOKEN=<token>` or `GIT_TOKEN=<token>`.

The following variable are availabe for interpolation on `commit_message`:

  `base_branch`, `branch`, `deploy_key`, `email`, `git_author_email`, `git_author_name`, `git_branch`, `git_commit_author`, `git_commit_msg`, `git_sha`, `git_tag`, `host`, `local_dir`, `name`, `repo`


### GitHub Pages



```
Usage: dpl pages git [options]

Summary:

  GitHub Pages deployment provider

Description:

  tbd

Options:

  Either token, or deploy_key are required.

  --repo SLUG                    Repo slug (type: string, default: repo slug)
  --token TOKEN                  GitHub token with repo permission (type: string, alias: github_token)
  --deploy_key PATH              Path to a file containing a private deploy key with write access to the
                                 repository (type: string, see:
                                 https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys)
  --target_branch BRANCH         Branch to push force to (type: string, default: gh-pages)
  --[no-]keep_history            Create incremental commit instead of doing push force (default: true)
  --commit_message MSG           type: string, default: Deploy %{project_name} to %{url}:%{target_branch}
  --[no-]allow_empty_commit      Allow an empty commit to be created (requires: keep_history)
  --[no-]verbose                 Be verbose about the deploy process
  --local_dir DIR                Directory to push to GitHub Pages (type: string, default: .)
  --fqdn FQDN                    Write the given domain name to the CNAME file (type: string)
  --project_name NAME            Used in the commit message only (defaults to fqdn or the current repo slug)
                                 (type: string)
  --name NAME                    Committer name (type: string, note: defaults to the current git commit author
                                 name)
  --email EMAIL                  Committer email (type: string, note: defaults to the current git commit author
                                 email)
  --[no-]committer_from_gh       Use the token's owner name and email for the commit (requires: token)
  --[no-]deployment_file         Enable creation of a deployment-info file
  --url URL                      type: string, alias: github_url, default: github.com

Common Options:

  --strategy NAME                GitHub Pages deployment strategy (type: string, default: git, known values: api,
                                 git)
  --cleanup                      Clean up build artifacts from the Git working directory before the deployment
  --run CMD                      Commands to execute after the deployment finished successfully (type: array
                                 (string, can be given multiple times))
  --help                         Get help on this command

Examples:

  dpl pages git --token token
  dpl pages git --deploy_key path
  dpl pages git --token token --repo slug --target_branch branch --keep_history --commit_message msg
```

Options can be given via env vars if prefixed with `[GITHUB_|PAGES_]`. E.g. the option `--token` can
be given as `GITHUB_TOKEN=<token>` or `PAGES_TOKEN=<token>`.

The following variable are availabe for interpolation on `commit_message`:

  `deploy_key`, `email`, `fqdn`, `git_author_email`, `git_author_name`, `git_branch`, `git_commit_author`, `git_commit_msg`, `git_sha`, `git_tag`, `local_dir`, `name`, `project_name`, `repo`, `target_branch`, `url`


### GitHub Pages (API)

Support for deployments to GitHub Pages (API) is in **development**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl pages api [options]

Summary:

  GitHub Pages (API) deployment provider

Description:

  This provider requests GitHub Pages build for the repository given by
  the `--repo` flag, or the current one, if the flag is not given.
  Note that `dpl` does not perform any check about the fitness of the request;
  it is assumed that the target repository (and the branch that GitHub Pages is
  configured to use) is ready for building.
  For example, if your GitHub Pages is configured to use `gh-pages` but the
  deployment is run on the `master` branch, you would have to ensure that the
  `gh-pages` would be updated accordingly during the build.

Options:

  --repo SLUG          GitHub repo slug (type: string, default: repo slug)
  --token TOKEN        GitHub oauth token with repo permission (type: string, required, alias:
                       github_token)

Common Options:

  --strategy NAME      GitHub Pages deployment strategy (type: string, default: git, known values: api,
                       git)
  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl pages api --token token
  dpl pages api --token token --repo slug --strategy api --cleanup --run cmd
```

Options can be given via env vars if prefixed with `[GITHUB_|PAGES_]`. E.g. the option `--token` can
be given as `GITHUB_TOKEN=<token>` or `PAGES_TOKEN=<token>`.

### GitHub Releases



```
Usage: dpl releases [options]

Summary:

  GitHub Releases deployment provider

Description:

  tbd

Options:

  Either token, or username and password are required.

  --token TOKEN                  GitHub oauth token (needs public_repo or repo permission) (type: string, alias:
                                 api_key)
  --username LOGIN               GitHub login name (type: string, alias: user)
  --password PASS                GitHub password (type: string)
  --repo SLUG                    GitHub repo slug (type: string, default: repo slug)
  --file GLOB                    File or glob to release to GitHub (type: array (string, can be given multiple
                                 times), default: *)
  --[no-]file_glob               Interpret files as globs (default: true)
  --[no-]overwrite               Overwrite files with the same name
  --[no-]prerelease              Identify the release as a prerelease
  --release_number NUM           Release number (override automatic release detection) (type: string)
  --release_notes STR            Content for the release notes (type: string, alias: body)
  --release_notes_file PATH      Path to a file containing the release notes (type: string, note: will be ignored
                                 if --release_notes is given)
  --[no-]draft                   Identify the release as a draft
  --tag_name TAG                 Git tag from which to create the release (type: string)
  --target_commitish STR         Commitish value that determines where the Git tag is created from (type: string)
  --name NAME                    Name for the release (type: string)

Common Options:

  --cleanup                      Clean up build artifacts from the Git working directory before the deployment
  --run CMD                      Commands to execute after the deployment finished successfully (type: array
                                 (string, can be given multiple times))
  --help                         Get help on this command

Examples:

  dpl releases --token token
  dpl releases --username login --password pass
  dpl releases --token token --repo slug --file glob --file_glob --overwrite
```

Options can be given via env vars if prefixed with `[GITHUB_|RELEASES_]`. E.g. the option `--token`
can be given as `GITHUB_TOKEN=<token>` or `RELEASES_TOKEN=<token>`.

### Gleis

Support for deployments to Gleis is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl gleis [options]

Summary:

  Gleis deployment provider

Description:

  tbd

Options:

  --app APP            Gleis application to upload to (type: string, default: repo name)
  --username NAME      Gleis username (type: string, required)
  --password PASS      Gleis password (type: string, required)
  --key_name NAME      Name of the SSH deploy key pushed to Gleis (type: string, default:
                       dpl_deploy_key)
  --[no-]verbose

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl gleis --username name --password pass
  dpl gleis --username name --password pass --app app --key_name name --verbose
```

Options can be given via env vars if prefixed with `GLEIS_`. E.g. the option `--password` can be
given as `GLEIS_PASSWORD=<password>`.

### Google App Engine



```
Usage: dpl gae [options]

Summary:

  Google App Engine deployment provider

Description:

  tbd

Options:

  --project ID                      Project ID used to identify the project on Google Cloud (type: string, required)
  --keyfile FILE                    Path to the JSON file containing your Service Account credentials in JSON Web
                                    Token format. To be obtained via the Google Developers Console. Should be
                                    handled with care as it contains authorization keys. (type: string, default:
                                    service-account.json)
  --config FILE                     Path to your service configuration file (type: array (string, can be given
                                    multiple times), default: app.yaml)
  --version VER                     The version of the app that will be created or replaced by this deployment. If
                                    you do not specify a version, one will be generated for you (type: string)
  --verbosity LEVEL                 Adjust the log verbosity (type: string, default: warning)
  --[no-]promote                    Whether to promote the deployed version (default: true)
  --[no-]stop_previous_version      Prevent the deployment from stopping a previously promoted version (default:
                                    true)
  --[no-]install_sdk                Whether to install the Google Cloud SDK (default: true)

Common Options:

  --cleanup                         Clean up build artifacts from the Git working directory before the deployment
  --run CMD                         Commands to execute after the deployment finished successfully (type: array
                                    (string, can be given multiple times))
  --help                            Get help on this command

Examples:

  dpl gae --project id
  dpl gae --project id --keyfile file --config file --version ver --verbosity level
```

Options can be given via env vars if prefixed with
`[CLOUDSDK_CORE|CLOUDSDK_CORE_|GAE|GAE_|GOOGLECLOUD|GOOGLECLOUD_]`.

### Google Cloud Store



```
Usage: dpl gcs [options]

Summary:

  Google Cloud Store deployment provider

Description:

  tbd

Options:

  Either key_file, or access_key_id and secret_access_key are required.

  --key_file FILE              Path to a GCS service account key JSON file (type: string)
  --access_key_id ID           GCS Interoperable Access Key ID (type: string)
  --secret_access_key KEY      GCS Interoperable Access Secret (type: string)
  --bucket BUCKET              GCS Bucket (type: string, required)
  --local_dir DIR              Local directory to upload from (type: string, default: .)
  --upload_dir DIR             GCS directory to upload to (type: string)
  --[no-]dot_match             Upload hidden files starting with a dot
  --acl ACL                    Access control to set for uploaded objects (type: string, default: private,
                               known values: private, public-read, public-read-write, authenticated-read,
                               bucket-owner-read, bucket-owner-full-control, see:
                               https://cloud.google.com/storage/docs/reference-headers#xgoogacl)
  --[no-]detect_encoding       HTTP header Content-Encoding to set for files compressed with gzip and compress
                               utilities.
  --cache_control HEADER       HTTP header Cache-Control to suggest that the browser cache the file. (type:
                               string, see:
                               https://cloud.google.com/storage/docs/xml-api/reference-headers#cachecontrol)
  --glob GLOB                  type: string, default: **/*

Common Options:

  --cleanup                    Clean up build artifacts from the Git working directory before the deployment
  --run CMD                    Commands to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --help                       Get help on this command

Examples:

  dpl gcs --bucket bucket --key_file file
  dpl gcs --bucket bucket --access_key_id id --secret_access_key key
  dpl gcs --bucket bucket
  dpl gcs --bucket bucket --key_file file --local_dir dir --upload_dir dir --dot_match
```

Options can be given via env vars if prefixed with `GCS_`. E.g. the option `--access_key_id` can be
given as `GCS_ACCESS_KEY_ID=<access_key_id>`.

### Hackage

Support for deployments to Hackage is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl hackage [options]

Summary:

  Hackage deployment provider

Description:

  tbd

Options:

  --username USER      Hackage username (type: string, required)
  --password USER      Hackage password (type: string, required)
  --[no-]publish       Whether or not to publish the package

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl hackage --username user --password user
  dpl hackage --username user --password user --publish --cleanup --run cmd
```

Options can be given via env vars if prefixed with `HACKAGE_`. E.g. the option `--password` can be
given as `HACKAGE_PASSWORD=<password>`.

### Hephy

Support for deployments to Hephy is in **beta**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl hephy [options]

Summary:

  Hephy deployment provider

Description:

  tbd

Options:

  --controller NAME      Hephy controller (type: string, required, e.g.: hephy.hephyapps.com)
  --username USER        Hephy username (type: string, required)
  --password PASS        Hephy password (type: string, required)
  --app APP              Deis app (type: string, required)
  --cli_version VER      Install a specific Hephy CLI version (type: string, default: stable)
  --[no-]verbose         Verbose log output

Common Options:

  --cleanup              Clean up build artifacts from the Git working directory before the deployment
  --run CMD              Commands to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --help                 Get help on this command

Examples:

  dpl hephy --controller name --username user --password pass --app app
  dpl hephy --controller name --username user --password pass --app app --cli_version ver
```

Options can be given via env vars if prefixed with `HEPHY_`. E.g. the option `--password` can be
given as `HEPHY_PASSWORD=<password>`.

### Heroku API



```
Usage: dpl heroku api [options]

Summary:

  Heroku API deployment provider

Description:

  tbd

Options:

  --api_key KEY        Heroku API key (type: string, required)

Common Options:

  --strategy NAME      Heroku deployment strategy (type: string, default: api, known values: api, git)
  --app APP            Heroku app name (type: string, default: repo name)
  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl heroku api --api_key key
  dpl heroku api --api_key key --strategy api --app app --cleanup --run cmd
```

Options can be given via env vars if prefixed with `HEROKU_`. E.g. the option `--api_key` can be
given as `HEROKU_API_KEY=<api_key>`.

### Heroku Git

Support for deployments to Heroku Git is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl heroku git [options]

Summary:

  Heroku Git deployment provider

Description:

  tbd

Options:

  Either api_key, or username and password are required.

  --api_key KEY        Heroku API key (type: string)
  --username USER      Heroku username (type: string, alias: user)
  --password PASS      Heroku password (type: string)
  --git URL            Heroku Git remote URL (type: string)

Common Options:

  --strategy NAME      Heroku deployment strategy (type: string, default: api, known values: api, git)
  --app APP            Heroku app name (type: string, default: repo name)
  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl heroku git --api_key key
  dpl heroku git --username user --password pass
  dpl heroku git --api_key key --git url --strategy api --app app --cleanup
```

Options can be given via env vars if prefixed with `HEROKU_`. E.g. the option `--api_key` can be
given as `HEROKU_API_KEY=<api_key>`.

### Launchpad

Support for deployments to Launchpad is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl launchpad [options]

Summary:

  Launchpad deployment provider

Description:

  tbd

Options:

  --oauth_token TOKEN              Launchpad OAuth token (type: string)
  --oauth_token_secret SECRET      Launchpad OAuth token secret (type: string)
  --slug SLUG                      Launchpad project slug (type: string, format: /^~[^\/]+\/[^\/]+\/[^\/]+$/, e.g.:
                                   ~user-name/project-name/branch-name)

Common Options:

  --cleanup                        Clean up build artifacts from the Git working directory before the deployment
  --run CMD                        Commands to execute after the deployment finished successfully (type: array
                                   (string, can be given multiple times))
  --help                           Get help on this command

Examples:

  dpl launchpad --oauth_token token --oauth_token_secret secret --slug slug --cleanup --run cmd
```

Options can be given via env vars if prefixed with `LAUNCHPAD_`. E.g. the option `--oauth_token` can
be given as `LAUNCHPAD_OAUTH_TOKEN=<oauth_token>`.

### Netlify



```
Usage: dpl netlify [options]

Summary:

  Netlify deployment provider

Description:

  tbd

Options:

  --site ID              A site ID to deploy to (type: string, required)
  --auth TOKEN           An auth token to log in with (type: string, required)
  --dir DIR              Specify a folder to deploy (type: string)
  --functions FUNCS      Specify a functions folder to deploy (type: string)
  --message MSG          A message to include in the deploy log (type: string)
  --[no-]prod            Deploy to production

Common Options:

  --cleanup              Clean up build artifacts from the Git working directory before the deployment
  --run CMD              Commands to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --help                 Get help on this command

Examples:

  dpl netlify --site id --auth token
  dpl netlify --site id --auth token --dir dir --functions funcs --message msg
```

Options can be given via env vars if prefixed with `NETLIFY_`. E.g. the option `--auth` can be given
as `NETLIFY_AUTH=<auth>`.

### npm



```
Usage: dpl npm [options]

Summary:

  npm deployment provider

Description:

  tbd

Options:

  --email EMAIL             npm account email (type: string)
  --api_token TOKEN         npm api token (type: string, required, alias: api_key, note: can be retrieved
                            from your local ~/.npmrc file, see:
                            https://docs.npmjs.com/creating-and-viewing-authentication-tokens)
  --access ACCESS           Access level (type: string, known values: public, private)
  --registry URL            npm registry url (type: string)
  --src SRC                 directory or tarball to publish (type: string, default: .)
  --tag TAGS                distribution tags to add (type: string)
  --run_script SCRIPT       run the given script from package.json (type: array (string, can be given
                            multiple times), note: skips running npm publish)
  --[no-]dry_run            performs test run without uploading to registry
  --auth_method METHOD      Authentication method (type: string, known values: auth)

Common Options:

  --cleanup                 Clean up build artifacts from the Git working directory before the deployment
  --run CMD                 Commands to execute after the deployment finished successfully (type: array
                            (string, can be given multiple times))
  --help                    Get help on this command

Examples:

  dpl npm --api_token token
  dpl npm --api_token token --email email --access public --registry url --src src
```

Options can be given via env vars if prefixed with `NPM_`. E.g. the option `--api_token` can be
given as `NPM_API_TOKEN=<api_token>`.

### nuget

Support for deployments to nuget is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl nuget [options]

Summary:

  nuget deployment provider

Description:

  tbd

Options:

  --api_key KEY              NuGet registry API key (type: string, required, note: can be retrieved from your
                             NuGet registry provider, see:
                             https://docs.npmjs.com/creating-and-viewing-authentication-tokens)
  --registry URL             NuGet registry url (type: string, required)
  --src SRC                  The nupkg file(s) to publish (type: string, default: *.nupkg)
  --[no-]no_symbols          Do not push symbols, even if present
  --[no-]skip_duplicate      Do not overwrite existing packages

Common Options:

  --cleanup                  Clean up build artifacts from the Git working directory before the deployment
  --run CMD                  Commands to execute after the deployment finished successfully (type: array
                             (string, can be given multiple times))
  --help                     Get help on this command

Examples:

  dpl nuget --api_key key --registry url
  dpl nuget --api_key key --registry url --src src --no_symbols --skip_duplicate
```

Options can be given via env vars if prefixed with `[DOTNET_|NUGET_]`. E.g. the option `--api_key`
can be given as `NUGET_API_KEY=<api_key>` or `DOTNET_API_KEY=<api_key>`.

### OpenShift



```
Usage: dpl openshift [options]

Summary:

  OpenShift deployment provider

Description:

  tbd

Options:

  --server SERVER        OpenShift server (type: string, required)
  --token TOKEN          OpenShift token (type: string, required)
  --project PROJECT      OpenShift project (type: string, required)
  --app APP              OpenShift application (type: string, default: repo name)

Common Options:

  --cleanup              Clean up build artifacts from the Git working directory before the deployment
  --run CMD              Commands to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --help                 Get help on this command

Examples:

  dpl openshift --server server --token token --project project
  dpl openshift --server server --token token --project project --app app --cleanup
```

Options can be given via env vars if prefixed with `OPENSHIFT_`. E.g. the option `--token` can be
given as `OPENSHIFT_TOKEN=<token>`.

### Packagecloud

Support for deployments to Packagecloud is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl packagecloud [options]

Summary:

  Packagecloud deployment provider

Description:

  tbd

Options:

  --username USER            The packagecloud.io username. (type: string, required)
  --token TOKEN              The packagecloud.io api token. (type: string, required)
  --repository REPO          The repository to push to. (type: string, required)
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

  --cleanup                  Clean up build artifacts from the Git working directory before the deployment
  --run CMD                  Commands to execute after the deployment finished successfully (type: array
                             (string, can be given multiple times))
  --help                     Get help on this command

Examples:

  dpl packagecloud --username user --token token --repository repo
  dpl packagecloud --username user --token token --repository repo --local_dir dir --dist dist
```

Options can be given via env vars if prefixed with `PACKAGECLOUD_`. E.g. the option `--token` can be
given as `PACKAGECLOUD_TOKEN=<token>`.

### Puppet Forge

Support for deployments to Puppet Forge is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl puppetforge [options]

Summary:

  Puppet Forge deployment provider

Description:

  tbd

Options:

  --username NAME      Puppet Forge user name (type: string, required, alias: user)
  --password PASS      Puppet Forge password (type: string, required)
  --url URL            Puppet Forge URL to deploy to (type: string, default:
                       https://forgeapi.puppetlabs.com/)

Common Options:

  --cleanup            Clean up build artifacts from the Git working directory before the deployment
  --run CMD            Commands to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --help               Get help on this command

Examples:

  dpl puppetforge --username name --password pass
  dpl puppetforge --username name --password pass --url url --cleanup --run cmd
```

Options can be given via env vars if prefixed with `PUPPETFORGE_`. E.g. the option `--password` can
be given as `PUPPETFORGE_PASSWORD=<password>`.

### PyPI



```
Usage: dpl pypi [options]

Summary:

  PyPI deployment provider

Description:

  tbd

Options:

  --username NAME               PyPI Username (type: string, required, alias: user)
  --password PASS               PyPI Password (type: string, required)
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

  --cleanup                     Clean up build artifacts from the Git working directory before the deployment
  --run CMD                     Commands to execute after the deployment finished successfully (type: array
                                (string, can be given multiple times))
  --help                        Get help on this command

Examples:

  dpl pypi --username name --password pass
  dpl pypi --username name --password pass --server server --distributions dists --docs_dir dir
```

Options can be given via env vars if prefixed with `PYPI_`. E.g. the option `--password` can be
given as `PYPI_PASSWORD=<password>`.

### Rubygems



```
Usage: dpl rubygems [options]

Summary:

  Rubygems deployment provider

Description:

  tbd

Options:

  Either api_key, or username and password are required.

  --api_key KEY            Rubygems api key (type: string)
  --username USER          Rubygems user name (type: string, alias: user)
  --password PASS          Rubygems password (type: string)
  --gem NAME               Name of the gem to release (type: string, default: repo name)
  --gemspec FILE           Gemspec file to use to build the gem (type: string)
  --gemspec_glob GLOB      Glob pattern to search for gemspec files when multiple gems are generated in the
                           repository (overrides the gemspec option) (type: string)
  --host URL               type: string

Common Options:

  --cleanup                Clean up build artifacts from the Git working directory before the deployment
  --run CMD                Commands to execute after the deployment finished successfully (type: array
                           (string, can be given multiple times))
  --help                   Get help on this command

Examples:

  dpl rubygems --api_key key
  dpl rubygems --username user --password pass
  dpl rubygems --api_key key --gem name --gemspec file --gemspec_glob glob --host url
```

Options can be given via env vars if prefixed with `RUBYGEMS_`. E.g. the option `--api_key` can be
given as `RUBYGEMS_API_KEY=<api_key>`.

### Scalingo

Support for deployments to Scalingo is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl scalingo [options]

Summary:

  Scalingo deployment provider

Description:

  tbd

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

  --cleanup              Clean up build artifacts from the Git working directory before the deployment
  --run CMD              Commands to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --help                 Get help on this command

Examples:

  dpl scalingo --api_token token
  dpl scalingo --username name --password pass
  dpl scalingo --api_token token --app app --region agora-fr1 --remote remote --branch branch
```

Options can be given via env vars if prefixed with `SCALINGO_`. E.g. the option `--password` can be
given as `SCALINGO_PASSWORD=<password>`.

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

Options:

  -s --script SCRIPT      The script to execute (type: string, required)

Common Options:

  --cleanup               Clean up build artifacts from the Git working directory before the deployment
  --run CMD               Commands to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --help                  Get help on this command

Examples:

  dpl script --script script
  dpl script --script script --cleanup --run cmd
```



### Snap



```
Usage: dpl snap [options]

Summary:

  Snap deployment provider

Description:

  tbd

Options:

  --token TOKEN       Snap API token (type: string, required)
  --snap STR          Path to the snap to be pushed (can be a glob) (type: string, default: **/*.snap)
  --channel CHAN      Channel into which the snap will be released (type: string, default: edge)

Common Options:

  --cleanup           Clean up build artifacts from the Git working directory before the deployment
  --run CMD           Commands to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --help              Get help on this command

Examples:

  dpl snap --token token
  dpl snap --token token --snap str --channel chan --cleanup --run cmd
```

Options can be given via env vars if prefixed with `SNAP_`. E.g. the option `--token` can be given
as `SNAP_TOKEN=<token>`.

### Surge



```
Usage: dpl surge [options]

Summary:

  Surge deployment provider

Description:

  tbd

Options:

  --login EMAIL       Surge login (the email address you use with Surge) (type: string, required)
  --token TOKEN       Surge login token (can be retrieved with `surge token`) (type: string, required)
  --domain NAME       Domain to publish to. Not required if the domain is set in the CNAME file in the
                      project folder. (type: string)
  --project PATH      Path to project directory relative to repo root (type: string, default: .)

Common Options:

  --cleanup           Clean up build artifacts from the Git working directory before the deployment
  --run CMD           Commands to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --help              Get help on this command

Examples:

  dpl surge --login email --token token
  dpl surge --login email --token token --domain name --project path --cleanup
```

Options can be given via env vars if prefixed with `SURGE_`. E.g. the option `--token` can be given
as `SURGE_TOKEN=<token>`.

### TestFairy

Support for deployments to TestFairy is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl testfairy [options]

Summary:

  TestFairy deployment provider

Description:

  tbd

Options:

  --api_key KEY                TestFairy API key (type: string, required)
  --app_file FILE              Path to the app file that will be generated after the build (APK/IPA) (type:
                               string, required)
  --symbols_file FILE          Path to the symbols file (type: string)
  --testers_groups GROUPS      Tester groups to be notified about this build (type: string, e.g.: e.g.
                               group1,group1)
  --[no-]notify                Send an email with a changelog to your users
  --[no-]auto_update           Automaticall upgrade all the previous installations of this app this version
  --advanced_options OPTS      Comma_separated list of advanced options (type: string, e.g.: option1,option2)

Common Options:

  --cleanup                    Clean up build artifacts from the Git working directory before the deployment
  --run CMD                    Commands to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --help                       Get help on this command

Examples:

  dpl testfairy --api_key key --app_file file
  dpl testfairy --api_key key --app_file file --symbols_file file --testers_groups groups --notify
```

Options can be given via env vars if prefixed with `TESTFAIRY_`. E.g. the option `--api_key` can be
given as `TESTFAIRY_API_KEY=<api_key>`.

### Transifex

Support for deployments to Transifex is in **alpha**. Please see [Maturity Levels](https://github.com/travis-ci/dpl/#maturity-levels) for details.

```
Usage: dpl transifex [options]

Summary:

  Transifex deployment provider

Description:

  tbd

Options:

  Either api_token, or username and password are required.

  --api_token TOKEN      Transifex API token (type: string)
  --username NAME        Transifex username (type: string)
  --password PASS        Transifex password (type: string)
  --hostname NAME        Transifex hostname (type: string, default: www.transifex.com)
  --cli_version VER      CLI version to install (type: string, default: >=0.11)

Common Options:

  --cleanup              Clean up build artifacts from the Git working directory before the deployment
  --run CMD              Commands to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --help                 Get help on this command

Examples:

  dpl transifex --api_token token
  dpl transifex --username name --password pass
  dpl transifex --api_token token --hostname name --cli_version ver --cleanup --run cmd
```

Options can be given via env vars if prefixed with `TRANSIFEX_`. E.g. the option `--api_token` can
be given as `TRANSIFEX_API_TOKEN=<api_token>`.

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
executable `dpl` is run with a given provider name as the first argument.

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
If you are adding a new deployment provider please familiarize yourself with
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

These live in [.travis/test_install](.travis/test_install). It is not
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
Travis CI. In order to do so, add proper configuration on the `edge` key to
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

In order to update the README please edit the template, and run:

```
gem install ffi-icu
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

5c077yP, A.J. May, A92hm, Aakriti Gupta, Aaron Hill, Aaron1011, Abdón Rodríguez Davila, Adam King, Adam Mcgrath, adinata, Adrian Moreno, Ahmad Nassri, Ahmed Refaey, Ainun Nazieb, Albertin Loic, Alex Jurkiewicz, Alexander Springer, Alexey Kotlyarov, Ali Hajimirza, Amos Wenger, Anders Olsen Sandvik, Andrew Nichols, Andrey Lushchick, Andy Vanbutsele, Angelo Livanos, Anne-Julia Seitz, Antoine Savignac, Anton Babenko, Anton Ilin, Arnold Daniels, Ashen Gunaratne, awesomescot, Axel Fontaine, Baptiste Courtois, Ben Hale, Benjamin Guttmann, Bob, Bob Zoller, Brad Gignac, Brandon Burton, Brandon LeBlanc, Brian Hou, Cameron White, capotej, Carla, carlad, Chad Engler, Chathan Driehuys, Chris Patterson, Christian Elsen, Christian Rackerseder, Clay Reimann, cleem, Cryptophobia, Damien Mathieu, Dan Buch, Dan Powell, Daniel X Moore, David F. Severski, Denis Cornehl, Dennis Koot, dependabot[bot], Devin J. Pohly, Dominic Jodoin, Dwayne Forde, emdantrim, Eric Peterson, Erik Dalén, Esteban Santiesteban, Étienne Michon, Eugene, Eugene Shubin, eyalbe4, Fabio Napoleoni, Felix Rieseberg, fgogolli, Filip Š, Flamur Gogolli, Gabriel Saldana, George Brighton, Gil, Gil Megidish, Gil Tselenchuk, Hao Luo, Hauke Stange, Henrik Hodne, Hiro Asari, IMANAKA, Kouta, Ivan Evtuhovich, Ivan Kusalic, Ivan Pozdeev, Jacob Burkhart, Jake Hewitt, Jakub Holy, James Adam, James Awesome, James Parker, Janderson, Jannis Leidel, Jeffrey Yasskin, Jeremy Frasier, JMSwag, Joe Damato, Joep van Delft, Johannes Würbach, johanneswuerbach, Johnny Dobbins, Jon Benson, Jon Rowe, Jon-Erik Schneiderhan, Jonatan Männchen, Jonathan Stites, Jonathan Sundqvist, jorgecasar, Josh Kalderimis, joshua-anderson, Jouni Kaplas, Julia S.Simon, Julio Capote, jung_b@localhost, Karim Fateem, Ke Zhu, konrad-c, Konstantin Haase, Kouta Imanaka, Kristofer Svardstal, Kyle Fazzari, Kyle VanderBeek, Loïc Mahieu, Lorenz Leutgeb, Lorne Currie, Louis Lagrange, Louis St-Amour, Luke Yeager, Maciej Skierkowski, Mahdi Nami Damirchi, Marc, María de Antón, mariadeanton, Mariana Lenetis and Zachary Gershman, Marius Gripsgard, Mark Pundsack, marscher, Marwan Rabbâa, Mathias Meyer, Mathias Rangel Wulff, Mathias San Miguel, Matt Hernandez, Matt Knox, Matt Travi, Matthew Knox, Maxime Brugidou, mayeut, Meir Gottlieb, Michael Bleigh, Michael Dunn, Michael Friis, Michel Boudreau, Mike Bryant, Nat Welch, Nicholas Bruning, Nick Mohoric, Nico Lindemann, Nigel Ramsay, Nikhil, Ole Michaelis, Olle Jonsson, Omer Katz, Patrique Legault, Paul Beaudoin, Paul Nikitochkin, Peter, Peter Georgantas, Peter Newman, Philipp Hansch, Piotr Sarnacki, Radek Lisowski, Radosław Lisowski, Rail Aliiev, Randall A. Gordon, Robert, Robert Gogolok, Rokas Brazdžionis, Romuald Bulyshko, root, ryanj, Ryn Daniels, Samir Talwar, Samuel Wright, Sandor Zeestraten, Sascha Zarhuber, SAULEAU Sven, Scot Spinner, Sebastien Estienne, Sergei Chertkov, shunyi, Simon, Solly, Sorin Sbarnea, Soulou, Stefan Harris, Stefan Kolb, Steffen Kötte, step76, Steven Berlanga, Sven Fuchs, Sviatoslav Sydorenko, testfairy, Tim Ysewyn, Troels Thomsen, Tyler Cross, Uriah Levy, Vincent Jacques, Vojtech Vondra, Vojtěch Vondra, Wael M. Nasreddine, Wen Kokke, Wim Looman, Xavier Krantz, yeonhoyoon, Zane Williamson
