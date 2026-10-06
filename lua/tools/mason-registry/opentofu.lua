return {
  name = 'opentofu',
  description = 'Open source infrastructure as code tool, a fork of Terraform',
  homepage = 'https://github.com/opentofu/opentofu',
  licenses = {
    'MPL-2.0',
  },
  languages = {
    'Terraform',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  -- mise installs it, as on the rest of the machine; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:opentofu',
  },
  bin = {
    tofu = 'tofu',
  },
}
