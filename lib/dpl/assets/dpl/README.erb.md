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

<% providers.each do |key, name| -%>
  * <%= "[#{name}](##{name.gsub(/\W+/, '-').downcase})" %>
<% end -%>

<% providers.each do |key, name|%>
### <%= name %>

```
<%= help(key) %>
```
<% end -%>

<%= File.read('./CONTRIBUTING.md').gsub(/^#/, '##') %>

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

<%= contributors %>
