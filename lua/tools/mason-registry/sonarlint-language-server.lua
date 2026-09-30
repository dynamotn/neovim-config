-- The release is tagged with a build number that the .vsix file it ships
-- leaves out, so both spellings are derived from one declaration instead of
-- drifting apart on the next bump.
-- renovate: datasource=github-releases depName=SonarSource/sonarlint-vscode
local version = '6.0.0+91043'
local release = version:match('^[^+]+')

return {
  name = 'sonarlint-language-server',
  description = 'SonarLint Language Server.',
  homepage = 'https://github.com/SonarSource/sonarlint-vscode',
  licenses = {
    'LGPL-3.0',
  },
  languages = {
    'AzureResourceManager',
    'C',
    'C++',
    'C#',
    'CloudFormation',
    'CSS',
    'Docker',
    'Go',
    'HTML',
    'IPython',
    'Java',
    'JavaScript',
    'Kubernetes',
    'TypeScript',
    'Python',
    'PHP',
    'Terraform',
    'Text',
    'XML',
    'YAML',
  },
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:github/SonarSource/sonarlint-vscode@' .. version,
    asset = {
      file = 'sonarlint-vscode-' .. release .. '.vsix',
    },
  },
  schemas = {
    lsp = 'vscode:https://raw.githubusercontent.com/SonarSource/sonarlint-vscode/{{version}}/package.json',
  },
  bin = {
    ['sonarlint-language-server'] = 'java-jar:extension/server/sonarlint-ls.jar',
  },
  share = {
    ['sonarlint-analyzers/'] = 'extension/analyzers/',
  },
  neovim = {
    lspconfig = 'sonarlint',
  },
}
