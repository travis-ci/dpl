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
