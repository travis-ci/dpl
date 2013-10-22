Deploy tool made for Continuous Deployment.

Usage:

    dpl --provider=heroku --api-key=`heroku auth:token`
    dpl --provider=cloudControl --deployment='<application>/<deployment>' --email=<email> --password=<password>

Supported providers:

* AppFog
* Cloud Foundry
* cloudControl
* dotCloud (experimental)
* Engine Yard
* Heroku
* Nodejitsu
* NPM
* Openshift
* PyPi
* RubyGems
* S3 (experimental)
