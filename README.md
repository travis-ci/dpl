Deploy tool made for Continuous Deployment.

Usage:

    dpl --provider=heroku --api-key=`heroku auth:token`
    dpl --provider=cloudControl --deployment='<application>/<deployment>' --email=<email> --password=<password>

Supported providers:

* Heroku
* Nodejitsu
* Openshift
* Engine Yard (experimental)
* dotCloud (experimental)
* RubyGems (experimental)
* cloudControl (experimental)
