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

### Note

Dpl will deploy by default from the latest commit. Use the `--skip_cleanup` option to deploy from the current file system state, which may include artifacts left by your build process. Note that providers that deploy via git may ignore this option.

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
