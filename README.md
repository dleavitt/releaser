# Releaser

Simple CLI util for generating changelogs with JIRA tickets.

## Installation

    $ gem install jira_release

## Usage

Run it with:

    $ releaser

Help:

    releaser full_log        # Changelog between all tags
    releaser help [COMMAND]  # Describe available commands or one specific command
    releaser log             # Changelog between current HEAD and last tag
    releaser release [tag]   # Create a tag

The first time it's run it will ask for a JIRA project slug and URL. It will store these in the project git config so you won't have to enter them again.

## Todo

- Deal more elegantly with creating tags on top of one another
- Link to Github commits
- Show JIRA ticket names
- Deal better with weird repos

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
