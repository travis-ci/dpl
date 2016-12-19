# Dpl [![Build Status](https://travis-ci.org/waghanza/dpl.svg?branch=master)](https://travis-ci.org/waghanza/dpl) [![Code Climate](https://codeclimate.com/github/waghanza/dpl.png)](https://codeclimate.com/github/waghanza/dpl) [![Coverage Status](https://coveralls.io/repos/waghanza/dpl/badge.svg?branch=master&service=github)](https://coveralls.io/github/waghanza/dpl?branch=master)

## PackageCloud

:information_source: Remove package before **deploy** :information_source: 

## Self Hosted

:information_source: `Push` deployment inspired by [capistrano](https://github.com/capistrano/capistrano) :information_source:

This custom **provider** push version using `ssh`.

### Configuration

~~~yaml
deploy:
  provider: self_hosted
  username: <USERNAME>
  hostname: <HOSTNAME>
  app: <APP>
  skip_cleanup: true
  edge:
    source: waghanza/dpl
    branch: self_hosted
~~~

### Usage

~~~sh
dpl --provider=self_hosted --username=<USERNAME> --hostname=<HOSTNAME> --skip_cleanup --app=<APP>
~~~

:warning: If no `ssh_key` provided, the ssh default home (`~/.ssh/id_rsa`) will be used :warning:
