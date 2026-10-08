return {
  name = 'foundry',
  description = 'Toolkit for Solidity, for the formatter forge ships',
  homepage = 'https://github.com/foundry-rs/foundry',
  licenses = {
    'MIT',
    'Apache-2.0',
  },
  languages = {
    'Solidity',
  },
  categories = {
    'Formatter',
  },
  -- mise installs it, as on the rest of the machine, so projects and the
  -- editor share one version; see `tools.mason-dytoy`
  source = {
    id = 'dytoy:foundry',
  },
  bin = {
    forge = 'forge',
  },
}
