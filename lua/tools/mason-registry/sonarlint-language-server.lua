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
    id = 'pkg:github/SonarSource/sonarlint-vscode@4.22.0%2B77643',
    asset = {
      file = 'sonarlint-vscode-4.22.0.vsix',
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
