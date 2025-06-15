return {
  name = 'ltcc',
  description = 'A tool integrates the LanguageTool API to parse, spell check, and correct the grammar of your code comments',
  homepage = 'https://github.com/dustinblackman/languagetool-code-comments',
  licenses = {
    'MIT',
  },
  languages = {
    'Astro',
    'Bash',
    'C++',
    'Css',
    'Dockerfile',
    'Elixir',
    'Go',
    'Hcl',
    'Html',
    'Javascript',
    'Jsx',
    'Lua',
    'Make',
    'Nix',
    'Python',
    'Rust',
    'Sql',
    'Toml',
    'Tsx',
    'Typescript',
    'Yaml',
  },
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:github/dustinblackman/languagetool-code-comments@v0.6.3',
    asset = {
      {
        target = 'darwin_arm64',
        file = 'languagetool-code-comments_{{ version | strip_prefix "v" }}_darwin_arm64.tar.gz',
        bin = 'languagetool-code-comments',
      },
      {
        target = 'darwin_x64',
        file = 'languagetool-code-comments_{{ version | strip_prefix "v" }}_darwin_amd64.tar.gz',
        bin = 'languagetool-code-comments',
      },
      {
        target = 'linux_arm64',
        file = 'languagetool-code-comments_{{ version | strip_prefix "v" }}_linux_arm64.tar.gz',
        bin = 'languagetool-code-comments',
      },
      {
        target = 'linux_x64',
        file = 'languagetool-code-comments_{{ version | strip_prefix "v" }}_linux_amd64.tar.gz',
        bin = 'languagetool-code-comments',
      },
      {
        target = 'win_x64',
        file = 'languagetool-code-comments_{{ version | strip_prefix "v" }}_windows_amd64.zip',
        bin = 'languagetool-code-comments.exe',
      },
    },
  },
  bin = {
    ltcc = '{{source.asset.bin}}',
  },
}
