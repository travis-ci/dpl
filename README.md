# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.png?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl)
 Dpl (dee-pee-ell) is a deploy tool made for continuous deployment.  Developed and used by Travis CI.

## Supported Providers:
Dpl supports the following providers:

* [AppFog](#appfog)
* [Cloud Foundry](#cloud-foundry)
* [cloudControl](#cloudcontroll)
* [dotCloud (experimental)](#dotcloud)
* [Engine Yard](#engine-yard)
* [Heroku](#heroku)
* [Nodejitsu](#nodejitsu)
* [NPM](#npm)
* [Openshift](#openshift)
* [PyPi](#pypi)
* [RubyGems](#rubygems)
* [S3](#s3)
* [Divshot.io](#divshot-io)

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

* **email**: cloudControll email.
* **password**: cloudControll password.
* **deployment**: cloudControll Deployment. Follows the format "APP_NAME/DEP_NAME".

#### Examples:

    dpl --provider=cloudcontroll --email=<email> --password<password> --deployment=`APP_NAME/DEP_NAME`

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

#### Examples:

    dpl --provider=pypi --user=<username> --password=<password>
    dpl --provider=pypi --user=<username> --password=<password> --server=`https://mypackageindex.com/index`

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

#### Examples:

    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket>

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
