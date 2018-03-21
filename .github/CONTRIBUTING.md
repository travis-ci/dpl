# Writing a new deployment provider

So you want to add a new deployment provider,
fix a bug, or add a new feature to an
existing provider.

That's great.

This document explains what you need to know in order
to accomplish the goal.

`dpl` is written in Ruby, and we assume that you have
a good understanding of how it works.

## General structure of the `dpl` code base

### `lib/dpl/provider`

Each provider code is a subclass of `DPL::Provider`,
and it lives under `lib/dpl/provider`.

```
lib
└── dpl
    ├── cli.rb
    ├── error.rb
    ├── provider
    │   ├── anynines.rb
    │   ├── atlas.rb
    │   ├── azure_webapps.rb
    │   ├── bintray.rb
    │   ├── bitballoon.rb
    │   ├── ⋮
 ```

`dpl` script will receive the provider name via `--provider`
command-line option; e.g.,

    dpl --provider=script …

and attempts to load it at run time.

In order to make `dpl` be aware of a provider code, put the provider
code in `lib/dpl/provider` and add a key-value pair to the `DPL::Provider::GEM_NAME_OF`
hash in `lib/dpl/provider.rb`.

For example:

```ruby
module DPL
  class Provider
    GEM_NAME_OF = {
      'NewProvider' => 'new_provider',
    }
  end
end
```

There is no standard for how the key and value are defined, but
we generally recommend adhering to the snake-case naming;
e.g., for the `CloudFoundry` class, the file (and the gem name) is
`cloud_foundry`.
(Please note that some existing provider codes violate this guideline.)

#### Basic structure of the provider code

When `dpl` loads the provider code, first it sets up dependencies
(install `apt` packages, `npm` modules, etc.).

Then the following methods on the provider code are invoked:

1. `#check_auth`: sets up (and ideally verifies) user credentials
1. `#check_app`: verify that the application is valid
1. `#push_app`: deploy the code

If you are trying to implement support for a new provider and this basic
flow does not suit your needs, be sure to seek help/advice.

### `spec/provider`

`dpl` uses [RSpec](https://github.com/rspec) for tests.
The specs reside in `spec/provider`, and each provider has the corresponding
`*_spec.rb` file to hold specs.

## Testing new code locally

To test it locally, first you need to write a corresponding `dpl-*.gemspec` file.
You can write this file from scratch, or use the `gemspec_for` helper
method, found in `gemspec_helper.rb`.
We recommend the helper to ensure consistency.
The important thing is that your new gem has a good runtime dependency, most
notably on `dpl`.

Once you have `dpl-*.gemspec`, you are ready to run specs. To do this,
call `spec-*` Rake task.

> This task (and others) are dynamically inferred from the presence of `dpl-*.gemspec`,
> so there is no need for you to touch `Rakefile`.

This Rake task builds and installs `dpl` and the provider gem from the local source,
installs dependencies and runs the specs in `spec/provider/*_spec.rb`.
For example, to run specs on the `s3` provider:

    $ bundle install
    $ rake spec-s3

If you have other versions of `dpl` and `dpl-*` gems before running the Rake task,
they may interfere with your tests.

If you suspect this interference, be sure to uninstall them by

    $ gem uninstall -aIx dpl dpl-* # for appropriate provider(s)

or

    $ rake clean

to completely clean up the working directory.

### Testing a portion of specs

The `spec-*` Rake tasks take an optional argument, which is passed on
to `rspec` to indicate which lines to execute.

For example:

    $ rake spec-s3["55"]

### Avoid making actual network calls

Deployment code often interact with external services to do the job.
It is tempting to make calls to external servers during the specs,
but resist this temptation.
Instead, mock the network calls and write specs that deal with different results.
Assuming that the external resources are stable in their behavior,
this will make the specs less susceptible to network issues.

# Testing `dpl` in the context of Travis CI builds

It is possible to test new deployment provider or new functionality
of dpl when it is used from the Travis CI build script.

To do so, add the following to your `.travis.yml`:

```yaml
deploy:
  provider: X
  edge:
    source: myown/dpl
    branch: foo
  on:
    branch: TEST_BRANCH # or all_branches: true
  ⋮ # rest of provider X configuration
```

This builds the `dpl` gem on the VM
from `https://github.com/myown/dpl`, the `foo` branch.
Then it installs the locally built gem,
and uses that to deploy.

Notice that this is not a merge commit, so it is important
that when you are testing your PR, the branch `foo` is up-to-date
with https://github.com/travis-ci/dpl/tree/master/.

When opening a PR, be sure to run at least one deployment with the new configuration,
and provide a link to the build in the PR.
