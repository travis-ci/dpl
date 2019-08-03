# Dpl [![Build Status](https://travis-ci.org/travis-ci/dpl.svg?branch=master)](https://travis-ci.org/travis-ci/dpl) [![Code Climate](https://codeclimate.com/github/travis-ci/dpl.png)](https://codeclimate.com/github/travis-ci/dpl) [![Gem Version](https://badge.fury.io/rb/dpl.png)](http://badge.fury.io/rb/dpl) [![Coverage Status](https://coveralls.io/repos/travis-ci/dpl/badge.svg?branch=master&service=github)](https://coveralls.io/github/travis-ci/dpl?branch=master)

## Development

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to Dpl.

## Supported Providers

Dpl supports the following providers:

<% providers.each do |key, name| -%>
  * <%= "[#{name}](##{name.gsub(/\W+/, '-').downcase})" %>
<% end -%>

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

### Cleaning up the Git working directory

Dpl v1 has cleaned up the Git working directory by default, using `git stash
--all`. The default for this option has been changed in dpl v2, and users now
need to opt in to cleaning up any left over artifacts from the build process
by passing the option `--cleanup`.

The status of the working directory is relevant only to providers that package
and push it to the respective remote service (e.g. `heroku` when using the
`api` strategy, package registry providers, etc.). Most providers will either
push the latest Git commit, or pull code from a remote repository.

## Providers
<% providers.each do |key, name|%>
### <%= name %>

```
<%= help(key) %>
```
<% end -%>

## Credits

TBD

## License

Dpl is licensed under the [MIT License](https://github.com/travis-ci/dpl/blob/master/LICENSE).
