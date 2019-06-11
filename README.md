# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.svg?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Gem Version](https://badge.fury.io/rb/dpl.png)](http://badge.fury.io/rb/dpl) [![Coverage Status](https://coveralls.io/repos/travis-ci/dpl/badge.svg?branch=master&service=github)](https://coveralls.io/github/travis-ci/dpl?branch=master)

## Development

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to Dpl.

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
  * [Bitballoon](#bitballoon)
  * [Bluemix Cloud Foundry](#bluemix-cloud-foundry)
  * [Boxfuse](#boxfuse)
  * [Cargo](#cargo)
  * [Catalyze](#catalyze)
  * [Chef Supermarket](#chef-supermarket)
  * [Cloud Files](#cloud-files)
  * [Cloud Foundry](#cloud-foundry)
  * [Cloud66](#cloud66)
  * [Deis](#deis)
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
  * [NPM](#npm)
  * [Open Shift](#open-shift)
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

## Providers

### Anynines

```
Usage: readme anynines [options]

Summary:

  Anynines deployment provider

Description:

  tbd


Options:

  --username USER         anynines username (type: string, required: true)
  --password PASS         anynines password (type: string, required: true)
  --organization ORG      anynines target organization (type: string, required: true)
  --space SPACE           anynines target space (type: string, required: true)
  --app_name APP          Application name (type: string)
  --manifest FILE         Path to the manifest (type: string)

Common Options:

  --run CMD               Command to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --skip_cleanup          Skip cleaning up build artifacts before the deployment
  --help                  Get help on this command

Examples:

  dpl anynines --username user --password pass --organization org --space space
  dpl anynines --username user --password pass --organization org --space space --app_name app
```

### Atlas

```
Usage: readme atlas [options]

Summary:

  Atlas deployment provider

Description:

  tbd


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
  --vcs                Get lists of files to exclude and include from a VCS (Git, Mercurial or SVN)
  --args ARGS          Args to pass to the atlas-upload CLI (type: string)
  --debug              Turn on debug output

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl atlas --app app --token token
  dpl atlas --app app --token token --paths path --address addr --include glob
```

### AWS Code Deploy

```
Usage: readme codedeploy [options]

Summary:

  AWS Code Deploy deployment provider

Description:

  tbd


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
  --wait_until_deployed         Wait until the deployment has finished
  --bundle_type TYPE            type: string
  --endpoint ENDPOINT           type: string
  --key KEY                     type: string
  --description DESCR           type: string

Common Options:

  --run CMD                     Command to execute after the deployment finished successfully (type: array
                                (string, can be given multiple times))
  --skip_cleanup                Skip cleaning up build artifacts before the deployment
  --help                        Get help on this command

Examples:

  dpl codedeploy --access_key_id id --secret_access_key key --application name
  dpl codedeploy --access_key_id id --secret_access_key key --application name --deployment_group group --revision_type s3
```

### AWS Elastic Beanstalk

```
Usage: readme elasticbeanstalk [options]

Summary:

  AWS Elastic Beanstalk deployment provider

Description:

  tbd


Options:

  --access_key_id ID             AWS Access Key ID (type: string, required: true)
  --secret_access_key KEY        AWS Secret Key (type: string, required: true)
  --region REGION                AWS Region the Elastic Beanstalk app is running in (type: string, default:
                                 us-east-1)
  --app NAME                     Elastic Beanstalk application name (type: string, default: repo name)
  --env NAME                     Elastic Beanstalk environment name which will be updated (type: string,
                                 required: true)
  --bucket_name NAME             Bucket name to upload app to (type: string, required: true)
  --bucket_path PATH             Location within Bucket to upload app to (type: string)
  --zip_file PATH                The zip file that you want to deploy (type: string, requires: skip_cleanup)
  --only_create_app_version      Only create the app version, do not actually deploy it
  --wait_until_deployed          Wait until the deployment has finished
  --label LABEL                  type: string
  --description DESC             type: string

Common Options:

  --run CMD                      Command to execute after the deployment finished successfully (type: array
                                 (string, can be given multiple times))
  --skip_cleanup                 Skip cleaning up build artifacts before the deployment
  --help                         Get help on this command

Examples:

  dpl elasticbeanstalk --access_key_id id --secret_access_key key --env name --bucket_name name
  dpl elasticbeanstalk --access_key_id id --secret_access_key key --env name --bucket_name name --region region
```

### AWS Lambda

```
Usage: readme lambda [options]

Summary:

  AWS Lambda deployment provider

Description:

  tbd


Options:

  --access_key_id ID                AWS access key id (type: string, required: true)
  --secret_access_key KEY           AWS secret key (type: string, required: true)
  --region REGION                   AWS region the Lambda function is running in (type: string, default: us-east-1)
  --function_name FUNC              Name of the Lambda being created or updated (type: string, required: true)
  --role ROLE                       ARN of the IAM role to assign to the Lambda function (type: string, required:
                                    true)
  --handler_name NAME               Function the Lambda calls to begin executio. (type: string, required: true)
  --dot_match                       Include hidden .* files to the zipped archive
  --module_name NAME                Name of the module that exports the handler (type: string, default: index)
  --zip PATH                        Path to a packaged Lambda, a directory to package, or a single file to package
                                    (type: string, default: .)
  --description DESCR               Description of the Lambda being created or updated (type: string)
  --timeout SECS                    Function execution time (in seconds) at which Lambda should terminate the
                                    function (type: string, default: 3)
  --memory_size MB                  Amount of memory in MB to allocate to this Lambda (type: string, default: 128)
  --runtime NAME                    Lambda runtime to use (type: string, default: node)
  --publish                         Create a new version of the code instead of replacing the existing one.
  --subnet_ids IDS                  List of subnet IDs to be added to the function. Needs the ec2:DescribeSubnets
                                    and ec2:DescribeVpcs permission for the user of the access/secret key to work.
                                    (type: array (string, can be given multiple times))
  --security_group_ids IDS          List of security group IDs to be added to the function. Needs the
                                    ec2:DescribeSecurityGroups and ec2:DescribeVpcs permission for the user of the
                                    access/secret key to work. (type: array (string, can be given multiple times))
  --dead_letter_arn ARN             ARN to an SNS or SQS resource used for the dead letter queue. (type: string)
  --tracing_mode MODE               Tracing mode (Needs xray:PutTraceSegments xray:PutTelemetryRecords on the role)
                                    (type: string, default: PassThrough, known values: Active, PassThrough)
  --environment_variables VARS      List of Environment Variables to add to the function, needs to be in the format
                                    of KEY=VALUE. Can be encrypted for added security. (type: array (string, can be
                                    given multiple times))
  --kms_key_arn ARN                 KMS key ARN to use to encrypt environment_variables. (type: string)
  --function_tags TAGS              List of tags to add to the function, needs to be in the format of KEY=VALUE. Can
                                    be encrypted for added security. (type: array (string, can be given multiple
                                    times))

Common Options:

  --run CMD                         Command to execute after the deployment finished successfully (type: array
                                    (string, can be given multiple times))
  --skip_cleanup                    Skip cleaning up build artifacts before the deployment
  --help                            Get help on this command

Examples:

  dpl lambda --access_key_id id --secret_access_key key --function_name func --role role --handler_name name
```

### AWS OpsWorks

```
Usage: readme opsworks [options]

Summary:

  AWS OpsWorks deployment provider

Description:

  tbd


Options:

  --access_key_id ID           AWS access key id (type: string, required: true)
  --secret_access_key KEY      AWS secret key (type: string, required: true)
  --app_id APP                 The app id (type: string, required: true)
  --region REGION              AWS region (type: string, default: us-east-1)
  --instance_ids ID            An instance id (type: array (string, can be given multiple times))
  --layer_ids ID               A layer id (type: array (string, can be given multiple times))
  --migrate                    Migrate the database.
  --wait_until_deployed        Wait until the app is deployed and return the deployment status.
  --update_on_success          When wait-until-deployed and updated-on-success are both not given, application
                               source is updated to the current SHA. Ignored when wait-until-deployed is not
                               given. (alias: update_app_on_success)
  --custom_json JSON           Custom json options override (overwrites default configuration) (type: string)

Common Options:

  --run CMD                    Command to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --skip_cleanup               Skip cleaning up build artifacts before the deployment
  --help                       Get help on this command

Examples:

  dpl opsworks --access_key_id id --secret_access_key key --app_id app
  dpl opsworks --access_key_id id --secret_access_key key --app_id app --region region --instance_ids id
```

### AWS S3

```
Usage: readme s3 [options]

Summary:

  AWS S3 deployment provider

Description:

  tbd


Options:

  --access_key_id ID                  AWS access key id (type: string, required: true)
  --secret_access_key KEY             AWS secret key (type: string, required: true)
  --bucket BUCKET                     S3 bucket (type: string, required: true)
  --region REGION                     S3 region (type: string, default: us-east-1)
  --endpoint URL                      S3 endpoint (type: string)
  --upload_dir DIR                    S3 directory to upload to (type: string)
  --storage_class CLASS               S3 storage class to upload as (type: string, default: STANDARD, known values:
                                      STANDARD, STANDARD_IA, REDUCED_REDUNDANCY)
  --server_side_encryption            Use S3 Server Side Encryption (SSE-AES256)
  --local_dir DIR                     Local directory to upload from (type: string, default: ., e.g.: ~/travis/build
                                      (absolute path) or ./build (relative path))
  --detect_encoding                   HTTP header Content-Encoding for files compressed with gzip and compress
                                      utilities
  --cache_control STR                 HTTP header Cache-Control to suggest that the browser cache the file (type:
                                      string, default: no-cache, known values: no-cache, no-store, /max-age=\d+/,
                                      /s-maxage=\d+/, no-transform, public, private)
  --expires DATE                      Date and time that the cached object expires (type: string, format:
                                      /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .+$/)
  --acl ACL                           Access control for the uploaded objects (type: string, default: private, known
                                      values: private, public_read, public_read_write, authenticated_read,
                                      bucket_owner_read, bucket_owner_full_control)
  --dot_match                         Upload hidden files starting with a dot
  --index_document_suffix SUFFIX      Index document suffix of a S3 website (type: string)
  --default_text_charset CHARSET      Default character set to append to the content-type of text files (type: string)
  --max_threads NUM                   The number of threads to use for S3 file uploads (type: integer, default: 5,
                                      max: 15)

Common Options:

  --run CMD                           Command to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --skip_cleanup                      Skip cleaning up build artifacts before the deployment
  --help                              Get help on this command

Examples:

  dpl s3 --access_key_id id --secret_access_key key --bucket bucket
  dpl s3 --access_key_id id --secret_access_key key --bucket bucket --region region --endpoint url
```

### Azure Web Apps

```
Usage: readme azure_web_apps [options]

Summary:

  Azure Web Apps deployment provider

Description:

  tbd


Options:

  --site SITE          Web App name (e.g. myapp in myapp.azurewebsites.net) (type: string, required:
                       true)
  --username NAME      Web App Deployment Username (type: string, required: true)
  --password PASS      Web App Deployment Password (type: string, required: true)
  --slot SLOT          Slot name (if your app uses staging deployment) (type: string)
  --verbose            Print deployment output from Azure. Warning: If authentication fails, Git prints
                       credentials in clear text. Correct credentials remain hidden.

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl azure_web_apps --site site --username name --password pass
  dpl azure_web_apps --site site --username name --password pass --slot slot --verbose
```

### Bintray

```
Usage: readme bintray [options]

Summary:

  Bintray deployment provider

Description:

  tbd


Options:

  --user USER              Bintray user (type: string, required: true)
  --key KEY                Bintray API key (type: string, required: true)
  --file FILE              Path to a descriptor file for the Bintray upload (type: string, required: true)
  --passphrase PHRASE      Passphrase as configured on Bintray (if GPG signing is used) (type: string)

Common Options:

  --run CMD                Command to execute after the deployment finished successfully (type: array
                           (string, can be given multiple times))
  --skip_cleanup           Skip cleaning up build artifacts before the deployment
  --help                   Get help on this command

Examples:

  dpl bintray --user user --key key --file file
  dpl bintray --user user --key key --file file --passphrase phrase --run cmd
```

### Bitballoon

```
Usage: readme bitballoon [options]

Summary:

  Bitballoon deployment provider

Description:

  BitBallon provides free simple static site hosting.
  
  This deployment provider helps you deploy to BitBallon easily.


Options:

  --access_token TOKEN      The access token (type: string, required: true)
  --site_id ID              The side id (type: string, required: true)
  --local_dir DIR           The sub-directory of the built assets for deployment (type: string, default: .)

Common Options:

  --run CMD                 Command to execute after the deployment finished successfully (type: array
                            (string, can be given multiple times))
  --skip_cleanup            Skip cleaning up build artifacts before the deployment
  --help                    Get help on this command

Examples:

  dpl bitballoon --access_token token --site_id id
  dpl bitballoon --access_token token --site_id id --local_dir dir --run cmd --skip_cleanup
```

### Bluemix Cloud Foundry

```
Usage: readme bluemixcloudfoundry [options]

Summary:

  Bluemix Cloud Foundry deployment provider

Description:

  tbd


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
  --skip_ssl_validation      Skip SSL validation

Common Options:

  --run CMD                  Command to execute after the deployment finished successfully (type: array
                             (string, can be given multiple times))
  --skip_cleanup             Skip cleaning up build artifacts before the deployment
  --help                     Get help on this command

Examples:

  dpl bluemixcloudfoundry --username user --password pass --organization org --space space
  dpl bluemixcloudfoundry --username user --password pass --organization org --space space --region ng
```

### Boxfuse

```
Usage: readme boxfuse [options]

Summary:

  Boxfuse deployment provider

Description:

  BitBallon does something.


Options:

  --user USER             type: string
  --secret SECRET         type: string
  --config_file FILE      type: string, alias: configfile (deprecated, please use config_file)
  --payload PAYLOAD       type: string
  --image IMAGE           type: string
  --env ENV               type: string
  --extra_args ARGS       type: string

Common Options:

  --run CMD               Command to execute after the deployment finished successfully (type: array
                          (string, can be given multiple times))
  --skip_cleanup          Skip cleaning up build artifacts before the deployment
  --help                  Get help on this command

Examples:

  dpl boxfuse --user user --secret secret --config_file file --payload payload --image image
```

### Cargo

```
Usage: readme cargo [options]

Summary:

  Cargo deployment provider

Description:

  tbd


Options:

  --token TOKEN       Cargo registry API token (type: string, required: true)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --skip_cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl cargo --token token
  dpl cargo --token token --run cmd --skip_cleanup --help
```

### Catalyze

```
Usage: readme catalyze [options]

Summary:

  Catalyze deployment provider

Description:

  tbd


Options:

  --target TARGET      The git remote repository to deploy to (type: string, required: true)
  --path PATH          Path to files to deploy (type: string, default: .)

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl catalyze --target target
  dpl catalyze --target target --path path --run cmd --skip_cleanup --help
```

### Chef Supermarket

```
Usage: readme chef_supermarket [options]

Summary:

  Chef Supermarket deployment provider

Description:

  tbd


Options:

  --user_id ID                 Chef Supermarket user name (type: string, required: true)
  --client_key KEY             Client API key file name (type: string, required: true)
  --cookbook_name NAME         Cookbook name (type: string, default: repo name)
  --cookbook_category CAT      Cookbook category in Supermarket (type: string, required: true, see:
                               https://docs.getchef.com/knife_cookbook_site.html#id12)

Common Options:

  --run CMD                    Command to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --skip_cleanup               Skip cleaning up build artifacts before the deployment
  --help                       Get help on this command

Examples:

  dpl chef_supermarket --user_id id --client_key key --cookbook_category cat
  dpl chef_supermarket --user_id id --client_key key --cookbook_category cat --cookbook_name name --run cmd
```

### Cloud Files

```
Usage: readme cloudfiles [options]

Summary:

  Cloud Files deployment provider

Description:

  tbd


Options:

  --username USER       Rackspace username (type: string, required: true)
  --api_key KEY         Rackspace API key (type: string, required: true)
  --region REGION       Cloudfiles region (type: string, required: true, known values: ord, dfw, syd,
                        iad, hkg)
  --container NAME      Name of the container that files will be uploaded to (type: string, required:
                        true)
  --glob GLOB           Paths to upload (type: string, default: **/*)
  --dot_match           Upload hidden files starting a dot

Common Options:

  --run CMD             Command to execute after the deployment finished successfully (type: array
                        (string, can be given multiple times))
  --skip_cleanup        Skip cleaning up build artifacts before the deployment
  --help                Get help on this command

Examples:

  dpl cloudfiles --username user --api_key key --region ord --container name
  dpl cloudfiles --username user --api_key key --region ord --container name --glob glob
```

### Cloud Foundry

```
Usage: readme cloudfoundry [options]

Summary:

  Cloud Foundry deployment provider

Description:

  tbd


Options:

  --username USER            Cloud Foundry username (type: string, required: true)
  --password PASS            Cloud Foundry password (type: string, required: true)
  --organization ORG         Cloud Foundry target organization (type: string, required: true)
  --space SPACE              Cloud Foundry target space (type: string, required: true)
  --api URL                  Cloud Foundry api URL (type: string, required: true)
  --app_name APP             Application name (type: string)
  --manifest FILE            Path to the manifest (type: string)
  --skip_ssl_validation      Skip SSL validation

Common Options:

  --run CMD                  Command to execute after the deployment finished successfully (type: array
                             (string, can be given multiple times))
  --skip_cleanup             Skip cleaning up build artifacts before the deployment
  --help                     Get help on this command

Examples:

  dpl cloudfoundry --username user --password pass --organization org --space space --api url
```

### Cloud66

```
Usage: readme cloud66 [options]

Summary:

  Cloud66 deployment provider

Description:

  tbd


Options:

  --redeployment_hook URL      The redeployment hook URL (type: string, required: true)

Common Options:

  --run CMD                    Command to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --skip_cleanup               Skip cleaning up build artifacts before the deployment
  --help                       Get help on this command

Examples:

  dpl cloud66 --redeployment_hook url
  dpl cloud66 --redeployment_hook url --run cmd --skip_cleanup --help
```

### Deis

```
Usage: readme deis [options]

Summary:

  Deis deployment provider

Description:

  tbd


Options:

  --controller NAME      Deis controller (type: string, required: true, e.g.: deis.deisapps.com)
  --username USER        Deis username (type: string, required: true)
  --password PASS        Deis password (type: string, required: true)
  --app APP              Deis app (type: string, required: true)
  --cli_version VER      Install a specific deis cli version (type: string, default: stable)
  --verbose              Verbose log output

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --skip_cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl deis --controller name --username user --password pass --app app
  dpl deis --controller name --username user --password pass --app app --cli_version ver
```

### Engineyard

```
Usage: readme engineyard [options]

Summary:

  Engineyard deployment provider

Description:

  tbd


Options:

  Either api_key, or email and password are required.

  --api_key KEY          Engine Yard API key (type: string)
  --email EMAIL          Engine Yard account email (type: string)
  --password PASS        Engine Yard password (type: string)
  --app APP              Engine Yard application name (type: string, default: repo name)
  --environment ENV      Engine Yard application environment (type: string)
  --migrate CMD          Engine Yard migration commands (type: string)
  --account NAME         Engine Yard account name (type: string)

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --skip_cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl engineyard --api_key key
  dpl engineyard --email email --password pass
  dpl engineyard --api_key key --app app --environment env --migrate cmd --account name
```

### Firebase

```
Usage: readme firebase [options]

Summary:

  Firebase deployment provider

Description:

  tbd


Options:

  --token TOKEN       Firebase CI access token (generate with firebase login:ci) (type: string,
                      required: true)
  --project NAME      Firebase project to deploy to (defaults to the one specified in your
                      firebase.json) (type: string)
  --message MSG       Message describing this deployment. (type: string)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --skip_cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl firebase --token token
  dpl firebase --token token --project name --message msg --run cmd --skip_cleanup
```

### GitHub Pages

```
Usage: readme pages [options]

Summary:

  GitHub Pages deployment provider

Description:

  tbd


Options:

  --github_token TOKEN        GitHub oauth token with repo permission (type: string, required: true)
  --repo SLUG                 Repo slug (type: string, default: repo slug)
  --target_branch BRANCH      Branch to push force to (type: string, default: gh-pages)
  --keep_history              Create incremental commit instead of doing push force
  --allow_empty_commit        Allow an empty commit to be created (requires: keep_history)
  --committer_from_gh         Use the token's owner name and email for commit. Overrides the email and name
                              options
  --verbose                   Be verbose about the deploy process
  --local_dir DIR             Directory to push to GitHub Pages (type: string, default: .)
  --fqdn FQDN                 Writes your website's domain name to the CNAME file (type: string)
  --project_name NAME         Used in the commit message only (defaults to fqdn or the current repo slug)
                              (type: string)
  --email EMAIL               Committer email (type: string, default: deploy@travis-ci.org)
  --name NAME                 Committer name (type: string, default: Deploy Bot)
  --deployment_file           Enable creation of a deployment-info file
  --github_url URL            type: string, default: github.com

Common Options:

  --run CMD                   Command to execute after the deployment finished successfully (type: array
                              (string, can be given multiple times))
  --skip_cleanup              Skip cleaning up build artifacts before the deployment
  --help                      Get help on this command

Examples:

  dpl pages --github_token token
  dpl pages --github_token token --repo slug --target_branch branch --keep_history --allow_empty_commit
```

### GitHub Releases

```
Usage: readme releases [options]

Summary:

  GitHub Releases deployment provider

Description:

  tbd


Options:

  Either api_key, or user and password are required.

  --api_key TOKEN             GitHub oauth token (needs public_repo or repo permission) (type: string)
  --username LOGIN            GitHub login name (type: string, alias: user)
  --password PASS             GitHub password (type: string)
  --repo SLUG                 GitHub repo slug (type: string, default: repo slug)
  --file FILE                 File to release to GitHub (type: array (string, can be given multiple times),
                              required: true)
  --file_glob                 Interpret files as globs
  --overwrite                 Overwrite files with the same name
  --prerelease                Identify the release as a prerelease
  --release_number NUM        Release number (overide automatic release detection) (type: string)
  --draft                     Identify the release as a draft
  --tag_name TAG              Git tag from which to create the release (type: string)
  --target_commitish STR      Commitish value that determines where the Git tag is created from (type: string)
  --name NAME                 Name for the release (type: string)
  --body BODY                 Content for the release notes (type: string)

Common Options:

  --run CMD                   Command to execute after the deployment finished successfully (type: array
                              (string, can be given multiple times))
  --skip_cleanup              Skip cleaning up build artifacts before the deployment
  --help                      Get help on this command

Examples:

  dpl releases --file file --api_key token
  dpl releases --file file --password pass
  dpl releases --file file
  dpl releases --file file --api_key token --username login --repo slug --file_glob
```

### Google App Engine

```
Usage: readme gae [options]

Summary:

  Google App Engine deployment provider

Description:

  tbd


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
  --no_promote                    Do not promote the deployed version
  --no_stop_previous_version      Prevent your deployment from stopping the previously promoted version. This is
                                  from the future, so might not work (yet).

Common Options:

  --run CMD                       Command to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --skip_cleanup                  Skip cleaning up build artifacts before the deployment
  --help                          Get help on this command

Examples:

  dpl gae --project id
  dpl gae --project id --keyfile file --config file --version ver --verbosity level
```

### Google Cloud Store

```
Usage: readme gcs [options]

Summary:

  Google Cloud Store deployment provider

Description:

  tbd


Options:

  --access_key_id ID           GCS Interoperable Access Key ID (type: string, required: true)
  --secret_access_key KEY      GCS Interoperable Access Secret (type: string, required: true)
  --bucket BUCKET              GCS Bucket (type: string, required: true)
  --acl ACL                    Access control to set for uploaded objects (type: string)
  --upload_dir DIR             GCS directory to upload to (type: string, default: .)
  --local_dir DIR              Local directory to upload from. Can be an absolute (~/travis/build) or relative
                               (build) path. (type: string, default: .)
  --dot_match                  Upload hidden files starting with a dot
  --detect_encoding            HTTP header Content-Encoding to set for files compressed with gzip and compress
                               utilities.
  --cache_control HEADER       HTTP header Cache-Control to suggest that the browser cache the file. (type:
                               string)

Common Options:

  --run CMD                    Command to execute after the deployment finished successfully (type: array
                               (string, can be given multiple times))
  --skip_cleanup               Skip cleaning up build artifacts before the deployment
  --help                       Get help on this command

Examples:

  dpl gcs --access_key_id id --secret_access_key key --bucket bucket
  dpl gcs --access_key_id id --secret_access_key key --bucket bucket --acl acl --upload_dir dir
```

### Hackage

```
Usage: readme hackage [options]

Summary:

  Hackage deployment provider

Description:

  tbd


Options:

  --username USER      Hackage username (type: string, required: true)
  --password USER      Hackage password (type: string, required: true)

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl hackage --username user --password user
  dpl hackage --username user --password user --run cmd --skip_cleanup --help
```

### Hephy

```
Usage: readme hephy [options]

Summary:

  Hephy deployment provider

Description:

  tbd


Options:

  --controller NAME      Hephy controller (type: string, required: true, e.g.: hephy.hephyapps.com)
  --username USER        Hephy username (type: string, required: true)
  --password PASS        Hephy password (type: string, required: true)
  --app APP              Deis app (type: string, required: true)
  --cli_version VER      Install a specific hephy cli version (type: string, default: stable)
  --verbose              Verbose log output

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --skip_cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl hephy --controller name --username user --password pass --app app
  dpl hephy --controller name --username user --password pass --app app --cli_version ver
```

### Heroku API

```
Usage: readme heroku api [options]

Summary:

  Heroku API deployment provider

Description:

  tbd


Options:

  --api_key KEY       Heroku API key (type: string, required: true)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --skip_cleanup      Skip cleaning up build artifacts before the deployment
  --app APP           Heroku app name (type: string, default: repo name)
  --help              Get help on this command

Examples:

  dpl heroku api --api_key key
  dpl heroku api --api_key key --run cmd --skip_cleanup --app app --help
```

### Heroku Git

```
Usage: readme heroku git [options]

Summary:

  Heroku Git deployment provider

Description:

  tbd


Options:

  Either api_key, or username and password are required.

  --api_key KEY        Heroku API key (type: string)
  --username USER      Heroku username (type: string, alias: user)
  --password PASS      Heroku password (type: string)
  --git URL            type: string

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --app APP            Heroku app name (type: string, default: repo name)
  --help               Get help on this command

Examples:

  dpl heroku git --api_key key
  dpl heroku git --username user --password pass
  dpl heroku git --api_key key --git url --run cmd --skip_cleanup --app app
```

### Launchpad

```
Usage: readme launchpad [options]

Summary:

  Launchpad deployment provider

Description:

  tbd


Options:

  --slug SLUG                      Launchpad project slug (type: string, format: /^~[^\/]+\/[^\/]+\/[^\/]+$/, e.g.:
                                   ~user-name/project-name/branch-name)
  --oauth_token TOKEN              Launchpad OAuth token (type: string)
  --oauth_token_secret SECRET      Launchpad OAuth token secret (type: string)

Common Options:

  --run CMD                        Command to execute after the deployment finished successfully (type: array
                                   (string, can be given multiple times))
  --skip_cleanup                   Skip cleaning up build artifacts before the deployment
  --help                           Get help on this command

Examples:

  dpl launchpad --slug slug --oauth_token token --oauth_token_secret secret --run cmd --skip_cleanup
```

### NPM

```
Usage: readme npm [options]

Summary:

  NPM deployment provider

Description:

  tbd


Options:

  --email EMAIL       NPM email address (type: string, required: true)
  --api_key KEY       NPM api key (can be retrieved from your local ~/.npmrc file) (type: string,
                      required: true)
  --tag TAGS          NPM distribution tags to add (type: string)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --skip_cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl npm --email email --api_key key
  dpl npm --email email --api_key key --tag tags --run cmd --skip_cleanup
```

### Open Shift

```
Usage: readme openshift [options]

Summary:

  Open Shift deployment provider

Description:

  tbd


Options:

  --user NAME                     OpenShift username (type: string, required: true)
  --password PASS                 OpenShift password (type: string, required: true)
  --domain DOMAIN                 OpenShift application domain (type: string, required: true)
  --app APP                       OpenShift application (type: string, default: repo name)
  --deployment_branch BRANCH      type: string

Common Options:

  --run CMD                       Command to execute after the deployment finished successfully (type: array
                                  (string, can be given multiple times))
  --skip_cleanup                  Skip cleaning up build artifacts before the deployment
  --help                          Get help on this command

Examples:

  dpl openshift --user name --password pass --domain domain
  dpl openshift --user name --password pass --domain domain --app app --deployment_branch branch
```

### Packagecloud

```
Usage: readme packagecloud [options]

Summary:

  Packagecloud deployment provider

Description:

  tbd


Options:

  --username USER            The packagecloud.io username. (type: string, required: true)
  --token TOKEN              The packagecloud.io api token. (type: string, required: true)
  --repository REPO          The repository to push to. (type: string, required: true)
  --local_dir DIR            The sub-directory of the built assets for deployment. (type: string, default: .)
  --dist DIST                Required for debian, rpm, and node.js packages (use "node" for node.js
                             packages). The complete list of supported strings can be found on the
                             packagecloud.io docs. (type: string)
  --force                    Whether package has to be (re)uploaded / deleted before upload
  --connect_timeout SEC      type: integer, default: 60
  --read_timeout SEC         type: integer, default: 60
  --write_timeout SEC        type: integer, default: 180
  --package_glob GLOB        type: array (string, can be given multiple times), default: ["**/*"]

Common Options:

  --run CMD                  Command to execute after the deployment finished successfully (type: array
                             (string, can be given multiple times))
  --skip_cleanup             Skip cleaning up build artifacts before the deployment
  --help                     Get help on this command

Examples:

  dpl packagecloud --username user --token token --repository repo
  dpl packagecloud --username user --token token --repository repo --local_dir dir --dist dist
```

### Puppet Forge

```
Usage: readme puppetforge [options]

Summary:

  Puppet Forge deployment provider

Description:

  tbd


Options:

  --user NAME          Puppet Forge user name (type: string, required: true)
  --password PASS      Puppet Forge password (type: string, required: true)
  --url URL            Puppet Forge URL to deploy to (type: string, default:
                       https://forgeapi.puppetlabs.com/)

Common Options:

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl puppetforge --user name --password pass
  dpl puppetforge --user name --password pass --url url --run cmd --skip_cleanup
```

### PyPI

```
Usage: readme pypi [options]

Summary:

  PyPI deployment provider

Description:

  tbd


Options:

  --username NAME                   PyPI Username (type: string, required: true, alias: user)
  --password PASS                   PyPI Password (type: string, required: true)
  --server SERVER                   Release to a different index (type: string, default:
                                    https://upload.pypi.org/legacy/)
  --distributions DISTS             Space-separated list of distributions to be uploaded to PyPI (type: string,
                                    default: sdist)
  --[no-]skip_upload_docs BOOL      Skip uploading documentation. Note that upload.pypi.org does not support
                                    uploading documentation. (default: true, see:
                                    https://github.com/travis-ci/dpl/issues/660)
  --docs_dir DIR                    Path to the directory to upload documentation from (type: string, default:
                                    build/docs)
  --skip_existing                   Do not overwrite an existing file with the same name on the server.
  --setuptools_version VER          type: string
  --twine_version VER               type: string
  --wheel_version VER               type: string

Common Options:

  --run CMD                         Command to execute after the deployment finished successfully (type: array
                                    (string, can be given multiple times))
  --skip_cleanup                    Skip cleaning up build artifacts before the deployment
  --help                            Get help on this command

Examples:

  dpl pypi --username name --password pass
  dpl pypi --username name --password pass --server server --distributions dists --skip_upload_docs
```

### Rubygems

```
Usage: readme rubygems [options]

Summary:

  Rubygems deployment provider

Description:

  tbd


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

  --run CMD                Command to execute after the deployment finished successfully (type: array
                           (string, can be given multiple times))
  --skip_cleanup           Skip cleaning up build artifacts before the deployment
  --help                   Get help on this command

Examples:

  dpl rubygems --api_key key
  dpl rubygems --password pass
  dpl rubygems --api_key key --gem name --gemspec file --gemspec_glob glob --username user
```

### Scalingo

```
Usage: readme scalingo [options]

Summary:

  Scalingo deployment provider

Description:

  tbd


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

  --run CMD            Command to execute after the deployment finished successfully (type: array
                       (string, can be given multiple times))
  --skip_cleanup       Skip cleaning up build artifacts before the deployment
  --help               Get help on this command

Examples:

  dpl scalingo --api_key key
  dpl scalingo --username name --password pass
  dpl scalingo --api_key key --remote remote --branch branch --app app --run cmd
```

### Script

```
Usage: readme script [options]

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

  --script ./script      The script to execute (type: string, required: true)

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --skip_cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl script --script ./script
  dpl script --script ./script --run cmd --skip_cleanup --help
```

### Snap

```
Usage: readme snap [options]

Summary:

  Snap deployment provider

Description:

  tbd


Options:

  --snap STR          Path to the snap to be pushed (can be a glob) (type: string, required: true)
  --channel CHAN      Channel into which the snap will be released (type: string, default: edge)
  --token TOKEN       Snap API token (type: string, required: true)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --skip_cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl snap --snap str --token token
  dpl snap --snap str --token token --channel chan --run cmd --skip_cleanup
```

### Surge

```
Usage: readme surge [options]

Summary:

  Surge deployment provider

Description:

  tbd


Options:

  --login EMAIL       Surge login (the email address you use with Surge) (type: string, required:
                      true)
  --token TOKEN       Surge login token (can be retrieved with `surge token`) (type: string, required:
                      true)
  --domain NAME       Domain to publish to. Not required if the domain is set in the CNAME file in the
                      project folder. (type: string)
  --project PAHT      Path to project directory relative to repo root (type: string, default: .)

Common Options:

  --run CMD           Command to execute after the deployment finished successfully (type: array
                      (string, can be given multiple times))
  --skip_cleanup      Skip cleaning up build artifacts before the deployment
  --help              Get help on this command

Examples:

  dpl surge --login email --token token
  dpl surge --login email --token token --domain name --project paht --run cmd
```

### Testfairy

```
Usage: readme testfairy [options]

Summary:

  Testfairy deployment provider

Description:

  tbd


Options:

  --api_key KEY                       TestFairy API key (type: string, required: true)
  --app_file FILE                     Path to the app file that will be generated after the build (APK/IPA) (type:
                                      string, required: true)
  --symbols_file FILE                 Path to the symbols file (type: string)
  --testers_groups GROUPS             Tester groups to be notified about this build (type: string, e.g.: e.g.
                                      group1,group1)
  --notify                            Send an email with a changelog to your users
  --auto_update                       Automaticall upgrade all the previous installations of this app this version
  --video_quality QUALITY             Video quality settings (one of: high, medium or low (type: string, default:
                                      high)
  --screenshot_interval INTERVAL      Interval at which screenshots are taken, in seconds (type: integer, known
                                      values: 1, 2, 10)
  --max_duration DURATION             Maximum session recording length (max: 24h) (type: string, default: 10m, e.g.:
                                      20m or 1h)
  --data_only_wifi                    Send video and recorded metrics only when connected to a wifi network.
  --record_on_background              Collect data while the app is on background.
  --[no-]video                        Video recording settings (default: true)
  --metrics METRICS                   Comma_separated list of metrics to record (type: string, see:
                                      http://docs.testfairy.com/Upload_API.html)
  --icon_watermark                    Add a small watermark to the app icon
  --advanced_options OPTS             Comma_separated list of advanced options (type: string, e.g.: option1,option2)

Common Options:

  --run CMD                           Command to execute after the deployment finished successfully (type: array
                                      (string, can be given multiple times))
  --skip_cleanup                      Skip cleaning up build artifacts before the deployment
  --help                              Get help on this command

Examples:

  dpl testfairy --api_key key --app_file file
  dpl testfairy --api_key key --app_file file --symbols_file file --testers_groups groups --notify
```

### Transifex

```
Usage: readme transifex [options]

Summary:

  Transifex deployment provider

Description:

  tbd


Options:

  --username NAME        Transifex username (type: string, required: true)
  --password PASS        Transifex password (type: string, required: true)
  --hostname NAME        Transifex hostname (type: string, default: www.transifex.com)
  --cli_version VER      CLI version to install (type: string, default: >=0.11)

Common Options:

  --run CMD              Command to execute after the deployment finished successfully (type: array
                         (string, can be given multiple times))
  --skip_cleanup         Skip cleaning up build artifacts before the deployment
  --help                 Get help on this command

Examples:

  dpl transifex --username name --password pass
  dpl transifex --username name --password pass --hostname name --cli_version ver --run cmd
```

## Credits

TBD

## License

Dpl is licensed under the [MIT License](https://github.com/travis-ci/dpl/blob/master/LICENSE).
