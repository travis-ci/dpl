# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.png?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Gem Version](https://badge.fury.io/rb/dpl.png)](http://badge.fury.io/rb/dpl)
 Dpl (dee-pee-ell) is a deploy tool made for continuous deployment.  Developed and used by Travis CI.

## Supported Providers:
Dpl supports the following providers:

* [AppFog](#appfog)
* [Cloud Foundry](#cloud-foundry)
* [cloudControl](#cloudcontrol)
* [dotCloud (experimental)](#dotcloud)
* [Engine Yard](#engine-yard)
* [Heroku](#heroku)
* [Nodejitsu](#nodejitsu)
* [NPM](#npm)
* [Openshift](#openshift)
* [PyPi](#pypi)
* [RubyGems](#rubygems)
* [S3](#s3)
* [Divshot.io](#divshotio)
* [Rackspace Cloud Files](#rackspace-cloud-files)
* [AWS OpsWorks](#opsworks)

## Installation:

Dpl is published to rubygems.

* Dpl requires ruby with a version greater than 1.8.7
* To install: `gem install dpl`

## Usage:

###Security Warning:

Running dpl in a terminal that saves history is insecure as your password/api key will be saved as plain text by it.

###Global Flags
* `--provider=<provider>` sets the provider you want to deploy to. Every provider has slightly different flags, which are documented in the section about your provider following.
*  Dpl will deploy by default from the latest commit. Use the `--skip_cleanup`  flag to deploy from the current file state. Note that many providers deploy by git and could ignore this option.


### Heroku:

#### Options:
* **api-key**: Heroku API Key
* **strategy[git/anvil]**: Deployment strategy for Dpl. Defaults to anvil.
* **app**: Heroku app name. Defaults to the name of your git repo.
* **username**: heroku username. Not necessary if api-key is used. Requires git strategy.
* **password**: heroku password. Not necessary if api-key is used. Requires git strategy.

#### Git vs Anvil Deploy:
* Anvil will run the [buildpack](https://devcenter.heroku.com/articles/buildpacks) compilation step on the Travis CI VM, whereas the Git strategy will run it on a Heroku dyno, which provides the same environment the application will then run under and might be slightly faster.
* The Git strategy allows using *user* and *password* instead of *api-key*.
* When using Git, Heroku might send you an email for every deploy, as it adds a temporary SSH key to your account.

As a rule of thumb, you should switch to the Git strategy if you run into issues with Anvil or if you're using the [user-env-compile](https://devcenter.heroku.com/articles/labs-user-env-compile) plugin.

#### Examples:

    dpl --provider=heroku --api-key=`heroku auth:token`
    dpl --provider=heroku --strategy=git --username=<username> --password=<password>  --app=<application>




### Nodejitsu:

#### Options:

* **username**: Nodejitsu Username
* **api-key**: Nodejitsu API Key

#### Examples:
    dpl --provider=nodejitsu --username=<username> --api-key=<api-key>

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

### Openshift:

#### Options:

* **username**: Openshift Username.
* **password**: Openshift Password.
* **domain**: Openshift Application Domain.
* **app**: Openshift Application. Defaults to git repo's name.

####Examples:

    dpl --provider=openshift --username=<username> --password=<password> --domain=<domain>
    dpl --provider=openshift --username=<username> --password=<password> --domain=<domain> --app=<app>

### cloudControl:

#### Options:

* **email**: cloudControl email.
* **password**: cloudControl password.
* **deployment**: cloudControl Deployment. Follows the format "APP_NAME/DEP_NAME".

#### Examples:

    dpl --provider=cloudcontrol --email=<email> --password<password> --deployment=`APP_NAME/DEP_NAME`

### RubyGems:

#### Options:

* **api-key**: Rubygems Api Key.

#### Examples:

    dpl --provider=rubygems --api-key=<api-key>

### PyPI:

#### Options:

* **user**: PyPI Username.
* **password**: PyPI Password.
* **server**: Optional. Only required if you want to release to a different index. Follows the form of "https://mypackageindex.com/index".
* **distributions**: A space-separated list of distributions to be uploaded to PyPI. Defaults to 'sdist'.
* **docs_dir**: A path to the directory to upload documentation from. Defaults to 'build/docs'

#### Examples:

    dpl --provider=pypi --user=<username> --password=<password>
    dpl --provider=pypi --user=<username> --password=<password> --server=`https://mypackageindex.com/index` --distributions='sdist bdist'

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
* **upload-dir**: S3 directory to upload to. Defaults to root directory.
* **local-dir**: Local directory to upload from. Can be set from a global perspective (~/travis/build) or relative perspective (build) Defaults to project root.

#### Examples:

    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket>
    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --local-dir= BUILD --upload-dir=BUILDS

### OpsWorks:

#### Options:

* **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **app-id**: The app ID.
* **migrate**: Migrate the database. (Default: false)

#### Examples:

    dpl --provider=opsworks --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --app-id=<app-id> --migrate


### Appfog:

#### Options:

* **email**: Appfog Email.
* **password**: Appfog Password.
* **app**: Appfog App. Defaults to git repo's name.

#### Examples:

    dpl --provider=appfog --email=<email> --password=<password>
    dpl --provider=appfog --email=<email> --password=<password> --app=<app>

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
* **target**: Cloud Foundry target cloud/URL
* **space**: Cloud Foundry target space

#### Examples:

    dpl --provider=cloudfoundry --username=<username> --password=<password> --organization=<organization> --target=<target> --space=<space>

### dotCloud:

#### Options:

* **api_key**: dotCloud api key.
* **app**: dotcloud app.
* **service**: dotcloud service to run commands on. Defaults to 'www'.

#### Examples:

    dpl --provider=dotcloud --api_key=<api_key> --app=<app>
    dpl --provider=dotcloud --api_key=<api_key> --app=<app> --service=<service>

### Rackspace Cloud Files:

#### Options:

* **username**: Rackspace Username.
* **api-key**: Rackspace API Key.
* **region**: Cloud Files Region. The region in which your Cloud Files container exists.
* **container**: Container Name. The container where you would like your files to be uploaded.

#### Examples:

    dpl --provider=cloudfiles --username=<username> --api-key=<api-key> --region=<region> --container=<container>
