return {
  name = 'jira',
  description = 'An interactive command line tool for Atlassian Jira',
  homepage = 'https://github.com/ankitpokhrel/jira-cli',
  licenses = {
    'MIT',
  },
  languages = {
    'GitCommit',
    'Markdown',
    'Text',
  },
  categories = {
    'LSP',
  },
  source = {
    id = 'pkg:github/ankitpokhrel/jira-cli@v1.7.0',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'jira_{{ version | strip_prefix "v" }}_macOS_arm64.tar.gz',
        bin = 'jira_{{ version | strip_prefix "v" }}_macOS_arm64/bin/jira',
      },
      {
        target = 'darwin_x64',
        file = 'jira_{{ version | strip_prefix "v" }}_macOS_x86_64.tar.gz',
        bin = 'jira_{{ version | strip_prefix "v" }}_macOS_x86_64/bin/jira',
      },
      {
        target = 'linux_arm64',
        file = 'jira_{{ version | strip_prefix "v" }}_linux_arm64.tar.gz',
        bin = 'jira_{{ version | strip_prefix "v" }}_linux_arm64/bin/jira',
      },
      {
        target = 'linux_x64',
        file = 'jira_{{ version | strip_prefix "v" }}_linux_x86_64.tar.gz',
        bin = 'jira_{{ version | strip_prefix "v" }}_linux_x86_64/bin/jira',
      },
      {
        target = 'win_x64',
        file = 'jira_{{ version | strip_prefix "v" }}_windows_x86_64.zip',
        bin = 'jira_{{ version | strip_prefix "v" }}_windows_x86_64/bin/jira.exe',
      },
    },
  },
  bin = {
    jira = '{{source.asset.bin}}',
  },
}
