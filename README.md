Deploy tool made for Continuous Deployment.

Usage:

    dpl --provider=heroku --api-key=`heroku auth:token`
    dpl --provider=cloudControl --deployment='<application>/<deployment>' --email=<email> --password=<password>

Supported providers:

* Heroku
* Nodejitsu
* Openshift
* cloudControl
* RubyGems
* PyPi
* Engine Yard
* Cloud Foundry
* dotCloud (experimental)
