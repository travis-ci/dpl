# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.svg?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Gem Version](https://badge.fury.io/rb/dpl.png)](http://badge.fury.io/rb/dpl)
 Dpl (dee-pee-ell) is a deploy tool made for continuous deployment.  Developed and used by Travis CI.

## Supported Providers:
Dpl supports the following providers:

* [AppFog](#appfog)
* [Biicode](#biicode)
* [BitBalloon](#bitballoon)
* [Cloud 66](#cloud-66)
* [Cloud Foundry](#cloud-foundry)
* [cloudControl](#cloudcontrol)
* [dotCloud (experimental)](#dotcloud)
* [Engine Yard](#engine-yard)
* [Heroku](#heroku)
* [Nodejitsu](#nodejitsu)
* [NPM](#npm)
* [OpenShift](#openshift)
* [PyPi](#pypi)
* [RubyGems](#rubygems)
* [S3](#s3)
* [Divshot.io](#divshotio)
* [Rackspace Cloud Files](#rackspace-cloud-files)
* [AWS OpsWorks](#opsworks)
* [Modulus](#modulus)
* [Github Releases](#github-releases)
* [Ninefold](#ninefold)
* [Hackage](#hackage)
* [Deis](#deis)
* [Google Cloud Storage](#google-cloud-storage)
* [Elastic Beanstalk](#elastic-beanstalk)
* [Puppet Forge](#puppet-forge)
* [packagecloud](#packagecloud)
* [Chef Supermarket](#chef-supermarket)
* [Lambda](#lambda)
* [TestFairy](#testfairy)

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




### Bintray:

#### Options:

* **file**: Path to a descriptor file, containing information for the Bintray upload.
* **user**: Bintray user
* **key**: Bintray API key
* **passphrase**: Optional. In case a passphrase is configured on Bintray and GPG signing is used.

#### Descriptor file example:
```groovy
{
	"package": {
		"name": "auto-upload",
		"repo": "maven",
		"subject": "myBintrayUser",
		"desc": "I was pushed completely automatically",
		"website_url": "www.jfrog.com",
 		"issue_tracker_url": "https://github.com/bintray/bintray-client-java/issues",
 		"vcs_url": "https://github.com/bintray/bintray-client-java.git",
 		"licenses": ["MIT"],
 		"labels": ["cool", "awesome", "gorilla"],
 		"public_download_numbers": false,
 		"public_stats": false,
 		"attributes": [{"name": "att1", "values" : ["val1"], "type": "string"},
     				   {"name": "att2", "values" : [1, 2.2, 4], "type": "number"},
     				   {"name": "att5", "values" : ["2014-12-28T19:43:37+0100"], "type": "date"}]
 	},
	"version": {
		"name": "0.5",
		"desc": "This is a version",
		"released": "2015-01-04",
		"vcs_tag": "0.5",
	 	"attributes": [{"name": "VerAtt1", "values" : ["VerVal1"], "type": "string"},
  					   {"name": "VerAtt2", "values" : [1, 3.3, 5], "type": "number"},
					   {"name": "VerAtt3", "values" : ["2015-01-01T19:43:37+0100"], "type": "date"}],
		"gpgSign": false
	},

	"files": 
		[
		{"includePattern": "", "excludePattern": "", "uploadPattern": ""},
		{"includePattern": "", "excludePattern": "", "uploadPattern": ""}
		],
	"publish": true
}
```

#### Examples:
    dpl --provider=bintray --file=<path> --user=<username> --key=<api-key>
    dpl --provider=bintray --file=<path> --user=<username> --key=<api-key> --passphrase=<passphrase>

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

####Examples:

    dpl --provider=openshift --user=<username> --password=<password> --domain=<domain>
    dpl --provider=openshift --user=<username> --password=<password> --domain=<domain> --app=<app>

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
    dpl --provider=pypi --user=<username> --password=<password> --server='https://mypackageindex.com/index' --distributions='sdist bdist_wheel'

### NPM:

#### Options:

* **email**: NPM email.
* **api-key**: NPM api key. Can be retrieved from your ~/.npmrc file.

#### Examples:

    dpl --provider=npm --email=<email> --api-key=<api-key>

### biicode:

#### Options:

* **user**: biicode username.
* **password**: biicode password.

#### Examples:

    dpl --provider=biicode --user=<user> --password=<password>


### S3:

#### Options:

* **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **bucket**: S3 Bucket.
* **region**: S3 Region. Defaults to us-east-1.
* **endpoint**: S3 Endpoint. Defaults to s3.amazonaws.com.
* **upload-dir**: S3 directory to upload to. Defaults to root directory.
* **local-dir**: Local directory to upload from. Can be set from a global perspective (~/travis/build) or relative perspective (build) Defaults to project root.
* **detect-encoding**: Set HTTP header `Content-Encoding` for files compressed with `gzip` and `compress` utilities. Defaults to not set.
* **cache_control**: Set HTTP header `Cache-Control` to suggest that the browser cache the file. Defaults to `no-cache`. Valid options are `no-cache`, `no-store`, `max-age=<seconds>`,`s-maxage=<seconds>` `no-transform`, `public`, `private`.
* **expires**: This sets the date and time that the cached object is no longer cacheable. Defaults to not set. The date must be in the format `YYYY-MM-DD HH:MM:SS -ZONE`.
* **acl**: Sets the access control for the uploaded objects. Defaults to `private`. Valid options are `private`, `public_read`, `public_read_write`, `authenticated_read`, `bucket_owner_read`, `bucket_owner_full_control`.
* **dot_match**: When set to `true`, upload files starting a `.`.
* **index_document_suffix**: Set the index document of a S3 website.

#### File-specific `Cache-Control` and `Expires` headers

It is possible to set file-specific `Cache-Control` and `Expires` headers using `value: file[, file]` format.

##### Example:

    --cache_control="no-cache: index.html"
    --expires="\"2012-12-21 00:00:00 -0000\": *.css, *.js"

#### Examples:

    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --acl=public_read
    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --detect-encoding --cache_control=max-age=99999 --expires="2012-12-21 00:00:00 -0000"
    dpl --provider=s3 --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --bucket=<bucket> --region=us-west-2 --local-dir= BUILD --upload-dir=BUILDS

### OpsWorks:

#### Options:

* **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
* **app-id**: The app ID.
* **migrate**: Migrate the database. (Default: false)
* **wait-until-deployed**: Wait until the app is deployed and return the deployment status. (Default: false)
#### Examples:

    dpl --provider=opsworks --access-key-id=<access-key-id> --secret-access-key=<secret-access-key> --app-id=<app-id> --migrate --wait-until-deployed


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
* **api**: Cloud Foundry api URL
* **space**: Cloud Foundry target space

#### Examples:

    dpl --provider=cloudfoundry --username=<username> --password=<password> --organization=<organization> --api=<api> --space=<space>

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
* **dot_match**: When set to `true`, upload files starting a `.`.

#### Examples:

    dpl --provider=cloudfiles --username=<username> --api-key=<api-key> --region=<region> --container=<container>

### GitHub Releases:

#### Options:

* **api-key**: GitHub oauth token with `public_repo` or`repo` permission.
* **user**: GitHub username. Not necessary if `api-key` is used.
* **password**: GitHub Password. Not necessary if `api-key` is used.
* **repo**: GitHub Repo. Defaults to git repo's name.
* **file**: File to upload to GitHub Release.
* **file_glob**: If files should be interpreted as globs (\* and \*\* wildcards). Defaults to false.
* **release-number**: Overide automatic release detection, set a release manually.

#### GitHub Two Factor Authentication

For accounts using two factor authentication, you have to use an oauth token as a username and password will not work.

#### Examples:

    dpl --provider=releases --api-key=<api-key> --file=build.tar.gz

### Cloud 66

#### Options:

* **redeployment_hook**: The redeployment hook URL. Available from the Information menu within the Cloud 66 portal.

#### Examples:

    dpl --provider=cloud66 --redeployment_hook=<url>

### Ninefold

#### Options:

* **auth_token**: Ninefold deploy auth token
* **app_id**: Ninefold deploy app ID

#### Examples:

    dpl --provider=ninefold --auth_token=<auth_token> --app_id=<app_id>

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

### Elastic Beanstalk:

#### Options:

 * **access-key-id**: AWS Access Key ID. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
 * **secret-access-key**: AWS Secret Key. Can be obtained from [here](https://console.aws.amazon.com/iam/home?#security_credential).
 * **region**: AWS Region the Elastic Beanstalk app is running in. Defaults to 'us-east-1'. Please be aware that this must match the region of the elastic beanstalk app.
 * **app**: Elastic Beanstalk application name.
 * **env**: Elastic Beanstalk environment name which will be updated.
 * **bucket_name**: Bucket name to upload app to.

#### Examples:

    dpl --provider=elasticbeanstalk --access-key-id=<access-key-id> --secret-access-key="<secret-access-key>" --app="example-app-name" --env="example-app-environment" --region="us-west-2"

### BitBalloon:

#### Options:

 * **access_token**: Optinoal. The access_token which can be found in the `.bitballoon` file after a deployment using the bitballoon CLI. Only required if no `.bitballoon` file is present.
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
 * **dist**: Required for deb and rpm. The complete list of supported strings can be found on the [packagecloud.io docs](https://packagecloud.io/docs#os_distro_version)

#### Examples:

    dpl --provider=packagecloud --username=packageuser --token=t0k3n --repository=myrepo
    dpl --provider=packagecloud --username=packageuser --token=t0k3n --repository=myrepo --dist=ubuntu/precise
    dpl --provider=packagecloud --username=packageuser --token=t0k3n --repository=myrepo --local-dir="${TRAVIS_BUILD_DIR}/pkgs" --dist=ubuntu/precise

### Chef Supermarket:

#### Options:

 * **user_id**: Required. The user name at Chef Supermarket.
 * **client_key**: Required. The client API key file name.
 * **cookbook_category**: Required. The cookbook category in Supermarket (see: https://docs.getchef.com/knife_cookbook_site.html#id12 )

#### Examples:

    dpl --provider=chef-supermarket --user-id=chef --client-key=.travis/client.pem --cookbook-category=Others

### Lambda:

#### Options: 

 * **function_name**: Required. The name of the Lambda being created / updated.
 * **role**: Required. The ARN of the IAM role to assign to this Lambda function.
 * **handler_name**: Required. The function that Lambda calls to begin execution. For NodeJS, it is exported function for the module.
 * **module_name**: Optional. The name of the module that exports the handler. Defaults to `index`.
 * **zip**: Optional. Either a path to an existing packaged (zipped) Lambda, a directory to package, or a single file to package. Defaults to `Dir.pwd`.
 * **description**: Optional. The description of the Lambda being created / updated. Defaults to "Deploy build #{context.env['TRAVIS_BUILD_NUMBER']} to AWS Lambda via Travis CI"
 * **timeout**: Optional. The function execution time at which Lambda should terminate the function. Defaults to 3 (seconds).
 * **memory_size**: Optional. The amount of memory in MB to allocate to this Lambda. Defaults to 128.

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

### TestFairy:

Your Android(apk)/iOS(ipa) file will be uploaded to TestFairy,
and your testers can start testing your app.

#### Options:
* **api-key**: TestFairy API Key (https://app.testfairy.com/settings/) run "travis encrypt --add deploy.api-key" on your repo.
* **app-file**: Path to the app file that will be generated after the build (APK/IPA).
* **symbols-file**: Path to the symbols file.
* **keystore-file**: Path to your keystore-file (must, only for android). http://docs.travis-ci.com/user/encrypting-files/
* **storepass**: storepass (must, only for android).
* **alias**: alias (must, only for android).
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

