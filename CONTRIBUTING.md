# Contributing to Dpl

Dpl is a central component in Travis CI, and has been around for a long time.

This library always has been a community effort first. There probably is not a
single person in the world who is familiar with all deployment providers
supported by Dpl. Thank you all for this!

This document is for you if you want to contribute to Dpl, be it by adding a new
deployment provider, fixing a bug, or adding a new feature.

Dpl has a [code of conduct](CODE_OF_CONDUCT.md),
please follow it in all interactions with the project.

Dpl is written in Ruby, and we assume that you familiarize yourself with our
documentation as much as needed.

Helpful resources are:

* The [Dpl README](README.md)
* The [Dpl API docs](https://www.rubydoc.info/github/travis-ci/dpl) on rubydocs.info
* The [Cl README](https://github.com/svenfuchs/cl/blob/master/README.md)

## Navigating the Dpl codebase

### Provider classes

All provider specific classes live in [dpl/providers](lib/dpl/providers).
These represent the CLI commands that are executed when the command line
exectuable `dpl` is run with a given provider name as the first argument.

For instance, the command `dpl s3 --bucket bucket` instantiates and runs the provider
class [S3](lib/dpl/providers/s3.rb).

Each provider is a subclass of `Dpl::Provider`, which is defined in
[dpl/provider.rb](lib/dpl/provider.rb). This class defines, amongst other
things, the order of stages that make up the deployment process.

The DSL that is used to declare features, dependencies, options etc. on the
concrete provider classes is defined in the module `Dpl::Provider::DSL`, in
[dpl/provider/dsl](lib/dpl/provider/dsl.rb).

Also of interest is [Dpl::Ctx::Bash](lib/dpl/ctx/bash.rb), the Bash execution
context, that runs shell commands, installs dependencies etc. (while the `Test`
context class is used for testing in order to keep your development machine
clean and safe when you run tests locally).

```
lib
└── dpl
    ├── assets                # Stores larger shell scripts
    ├── ctx
    │   ├── bash.rb           # Bash execution context
    │   └── test.rb           # Test execution context
    ├── provider.rb           # Base class for all providers
    ├── provider
    │   ├── dsl.rb            # DSL for defining providers
    │   └── example.rb        # Generating example commands for help output
    └── providers
        ├── anynines.rb       # Concrete providers
        ├── atlas.rb
        ├── azure_webapps.rb
        ├── bintray.rb
        ├── bitballoon.rb
        └── ⋮
```

#### Lifecycle of the deployment process

When a provider class is instantiated and run it will go through a number
of stages that make up the deployment process.

These are documented in [dpl/provider.rb](/lib/dpl/provider.rb). If you are
adding a new deployment provider please familiarize youself with this
lifecycle.

Feel free to pick and interpret these stages according to the needs and
semantics of the service provider you are adding. By no means do all of these
stages have to be filled in or implmented. The `Provider` base class checks for
these methods, and runs them, if present, so that implementors can choose
semantically fitting names for their providers.

#### Deployment tooling

If you are adding a new deployment provider please choose the tooling you are
going to use carefully.

Dpl is a long lived library, and it has outlived many tools that once were
supported, and no longer are. Thus tooling stability is a major concern for
this project.

Ideally use official CLI tooling supported by the company who's service
provider you are about to add. Often, such CLI tools can be installed via
standard package managers, or manually downloaded using `curl` and installed
with a few simple Bash commands.

Such CLI tooling is preferrable over Ruby gem runtime dependencies as they can
be executed in a child process, and won't introduce any dependency resolution
problems later on.

If no such CLI is available, or it does not look well supported, and your
provider implementation needs to talk to an external HTTP API then please consider
using [Net::HTTP](https://ruby-doc.org/stdlib-2.6.3/libdoc/net/http/rdoc/Net/HTTP.html)
from Ruby's standard library.

If you absolutely have to rely on a runtime Ruby gem dependency, such as a
provider client implementation, please only do so if the gem is supported by
the respective company officially. We may choose to reject including runtime
dependencies that do not look stable or widely supported.

#### Runtime dependencies and local development

Runtime dependencies can be declared on the provider class using the
[DSL](lib/dpl/provider/dsl.rb). Ruby gem runtime dependencies, if any,
additinally have to be added to the [Gemfile](Gemfile) for them to be present
at test run time.

#### Running the tests locally

You can run the test suite locally as follows:

```
bundle install
bundle exec rspec
```

In order to execute tests only for a certain provider you can run:

```
bundle exec rspec spec/dpl/providers/[provider_name]_spec.rb
```

In order to execute a single test or group of tests add a line number like so:

```
bundle exec rspec spec/dpl/providers/[provider_name]_spec.rb:25
```

These tests can be run safely on any development machine, anywhere.

On Travis CI we additionally run tests that exercise runtime dependency
installation. These live in [.travis/test_install.rb](.travis/test_install.rb).
It is not advisable to run these tests outside of a VM or container that can be
safely discareded.

#### Writing tests

`Dpl` uses [RSpec](https://github.com/rspec) for tests. The specs reside in
`spec`, and each provider class has a corresponding file
`spec/dpl/providers/*_spec.rb` to hold tests.

Provider tests should be implemented on an input/output acceptance level, as
much as possible.

They use a [Ctx::Test](lib/dpl/ctx/test.rb) execution context in order to avoid
running actual shell commands, or actually installing dependencies at test
time. There are custom [RSpec matchers](spec/support/matchers) in place that
help with making assertions against this execution context.

If your provider has to talk to an external HTTP API then ideally use
[Webmock](https://github.com/bblimke/webmock) to stub external requests. If by
any means possible try to avoid mocking or stubbing Ruby client classes (this
is not always possible, but should be considered).

# Testing Dpl on Travis CI

It is possible to test new deployment provider or new functionality of Dpl on
Travis CI.

To do so, add the following to your `.travis.yml`:

```yaml
deploy:
  provider: [name]
  edge:
    source: [github-handle]/dpl
    branch: [branch]
  on:
    branch: TEST_BRANCH # or all_branches: true
  ⋮ # rest of your provider's configuration
```

This builds the `dpl` gem on the Travis CI build environment from your
repository, on the given branch. Then it installs the locally built gem, and
uses it to run your deployment.

When submitting a pull request, please be sure to run at least one deployment
with the new configuration, and provide a link to the build in your pull
request.

#### Code conventions

Dpl does not follow any strict code styleguide.

Please take a look around other providers, and try to follow a similar code
style to what you find.

If you are rather unfamiliar with Ruby, and have trouble following our code
style then please submit your pull request anyway, so we can help.

#### Naming conventions

Dpl uses constant names following Ruby naming conventions. I.e. constant
names use `CamelCase`, and they live in files named in `snake_case.rb`.

If you pick such names for a new provider please try to follow these
conventions.

Real world service provider or company names do not always translate to such
conventional Ruby names one-to-one. That is ok, they don't have to. These Ruby
constant names are representations of real world service and company names in
Ruby code.

Other Ruby libraries often (not always) follow a similar thinking. E.g.
even though Amazon Web Services brand name is `AWS` the module name
they chose in their [aws-sdk](https://github.com/aws/aws-sdk-ruby) is
`Aws`, not `AWS`.

## Automatic closure of old issues

If an issue has been left open and untouched for 90 days or more, we automatically
close them. We do this to ensure that new issues are more easily noticeable, and
that old issues that have been resolved or are no longer relevant are closed.
You can read more about this [here](https://blog.travis-ci.com/2018-03-09-closing-old-issues).
