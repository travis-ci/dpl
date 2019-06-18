require './gemspec_helper'

gemspec_for 'releases', [
  ['octokit', '~> 4.6.2'],
  ['mime-types', '~> 3.0'],
  ['public_suffix', '< 3.1.0']
]
