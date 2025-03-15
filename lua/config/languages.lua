---@class DyLangSpec
---@field filetypes string[]
---@field parsers (string|DyParserSpec)[]
---@field lsp_servers? string[]
---@field linters? (string|DyLinterSpec)[]
---@field formatters? (string|DyFormatterSpec)[]
---@field null_ls? DyNullLsSpec[]
---@field dap? string[]
---@field test? string[]
---@field dial? fun(): Augend[]
---@field autopairs? fun(filetypes: string[], rule: Rule, cond: CondOpts, ts_cond: table): Rule[]
---@field endwise? boolean
---@field otter? boolean

---@class DyParserSpec
---@field [1] string
---@field install_info DyParserInstallSpec

---@class DyParserInstallSpec:InstallInfo
---@field url string
---@field files string[]

---@class DyLinterSpec
---@field [1] string
---@field opts? table
---@field command? string

---@class DyFormatterSpec
---@field [1] string
---@field opts? table
---@field command? string

---@class DyNullLsSpec
---@field [1] string
---@field type string
---@field command string
---@field custom? boolean

---@alias DyLangRootSpec table<string,DyLangSpec>
---@type DyLangRootSpec
return {
  ---@diagnostic disable-next-line: missing-fields
  ['*'] = { -- For all filetypes
    filetypes = { '*' },
    formatters = {
      { 'trim_whitespace', command = 'lua' },
      { 'trim_newlines', command = 'lua' },
    },
    linters = { 'typos' },
    null_ls = {
      { 'dictionary', type = 'hover', command = 'curl' },
      { 'trail_space', type = 'diagnostics', command = 'lua' },
      { 'gitsigns', type = 'code_actions', command = 'git' },
    },
  },
  ---@diagnostic disable-next-line: missing-fields
  ['_'] = { -- For only non-configured filetypes
    filetypes = { '_' },
    linters = {
      { 'compiler', command = 'lua' },
    },
  },

  -- Programming language & Frameworks {
  angular = { -- See `html` and `javascript`
    filetypes = { 'htmlangular' },
    parsers = { 'angular' },
    lsp_servers = { 'angularls', 'harper_ls' },
    linters = { 'biomejs' },
    formatters = { 'biome', 'html_beautify' },
  },
  arduino = {
    filetypes = { 'arduino' },
    parsers = { 'cpp' },
    lsp_servers = { 'arduino_language_server' },
    linters = { 'clang-tidy' },
    formatters = { 'clang-format' },
  },
  awk = {
    filetypes = { 'awk' },
    parsers = {
      {
        'awk',
        install_info = {
          url = 'https://github.com/Beaglefoot/tree-sitter-awk',
          files = { 'src/parser.c', 'src/scanner.c' },
        },
      },
    },
    lsp_servers = { 'awk_ls' },
    linters = { 'gawk' },
    formatters = { 'gawk' },
  },
  bash = {
    filetypes = {
      'sh',
      'bats',
      'sh.ebuild',
      'sh.PKGBUILD',
    },
    parsers = { 'bash' },
    lsp_servers = {
      'bashls',
      'termuxls',
      'harper_ls',
    },
    linters = { 'shellcheck' },
    formatters = {
      'shellcheck',
      {
        'shfmt',
        opts = {
          prepend_args = {
            '-i',
            '2',
            '-ci',
            '-bn',
            '-sr',
          },
        },
      },
    },
    dap = { 'bash-debug-adapter' },
    test = { 'vim-test' },
    endwise = true,
  },
  cpp = {
    filetypes = { 'c', 'cpp' },
    parsers = { 'cpp' },
    lsp_servers = { 'clangd', 'harper_ls' },
    linters = { 'clang-tidy' },
    formatters = { 'clang-format' },
    dap = { 'codelldb' },
    test = {
      'neotest-gtest',
      'vim-test',
    },
  },
  c_sharp = {
    filetypes = { 'cs' },
    parsers = { 'c_sharp' },
    lsp_servers = { 'omnisharp', 'harper_ls' },
    formatters = {
      {
        'csharpier',
        opts = {
          command = 'dotnet-csharpier',
          args = { '--write-stdout' },
        },
      },
    },
    dap = { 'netcoredbg' },
    test = { 'neotest-dotnet' },
  },
  css = {
    filetypes = { 'css', 'less' },
    parsers = { 'css' },
    lsp_servers = { 'tailwindcss' },
    linters = { 'stylelint' },
    formatters = { 'prettier' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.hexcolor.new({
          case = 'lower',
        }),
        augend.hexcolor.new({
          case = 'upper',
        }),
      }
    end,
  },
  cucumber = {
    filetypes = { 'cucumber' },
    parsers = {
      {
        'gherkin',
        install_info = {
          url = 'https://github.com/binhtran432k/tree-sitter-gherkin',
          files = { 'src/parser.c', 'src/scanner.c' },
        },
      },
    },
    lsp_servers = { 'cucumber_language_server' },
  },
  fish = {
    filetypes = { 'fish' },
    parsers = { 'fish' },
    lsp_servers = { 'fish_lsp' },
    linters = { 'fish' },
    endwise = true,
  },
  go = {
    filetypes = { 'go', 'gomod', 'gowork', 'gosum' },
    parsers = { 'go', 'gomod', 'gowork', 'gosum' },
    lsp_servers = { 'gopls', 'harper_ls' },
    formatters = { 'goimports', 'gofumpt' },
    null_ls = {
      { 'gomodifytags', type = 'code_actions', command = 'gomodifytags' },
      { 'impl', type = 'code_actions', command = 'impl' },
    },
    dap = { 'delve' },
    test = { 'neotest-golang' },
  },
  html = {
    filetypes = { 'html' },
    parsers = { 'html' },
    lsp_servers = { 'emmet_ls', 'tailwindcss', 'html', 'harper_ls' },
    formatters = { 'html_beautify' },
  },
  java = {
    filetypes = { 'java' },
    parsers = { 'java' },
    lsp_servers = { 'jdtls', 'harper_ls' },
    dap = { 'java-debug-adapter' },
    test = { 'neotest-java' },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.constant.new({
          elements = { 'public', 'protected', 'private' },
          word = true,
          cyclic = true,
        }),
      }
    end,
  },
  latex = {
    filetypes = { 'tex' },
    parsers = { 'latex' },
    lsp_servers = { 'ltex', 'texlab' },
    formatters = { 'tex-fmt' },
  },
  lua = {
    filetypes = { 'lua' },
    parsers = { 'lua' },
    lsp_servers = { 'lua_ls', 'harper_ls' },
    formatters = { 'stylua' },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.constant.new({
          elements = { 'and', 'or' },
          word = true,
          cyclic = true,
        }),
      }
    end,
    endwise = true,
  },
  php = {
    filetypes = { 'php' },
    parsers = { 'php' },
    lsp_servers = { 'intelephense', 'harper_ls' },
    linters = { 'phpcs' },
    formatters = { 'php_cs_fixer' },
    dap = { 'php-debug-adapter' },
    test = { 'neotest-phpunit' },
  },
  python = {
    filetypes = { 'python' },
    parsers = { 'python' },
    lsp_servers = { 'pyright', 'harper_ls' },
    linters = { 'ruff' },
    formatters = {
      {
        'ruff_fix',
        command = 'ruff',
      },
      {
        'ruff_format',
        command = 'ruff',
      },
      {
        'ruff_organize_imports',
        command = 'ruff',
      },
    },
    dap = { 'debugpy' },
    test = { 'neotest-python' },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.constant.new({
          elements = { 'and', 'or' },
          word = true,
          cyclic = true,
        }),
      }
    end,
  },
  ruby = {
    filetypes = { 'ruby' },
    parsers = { 'ruby' },
    lsp_servers = { 'ruby_lsp', 'harper_ls' },
    linters = { 'rubocop' },
    formatters = { 'rubocop' },
    test = {
      'neotest-rspec',
      'vim-test',
    },
    endwise = true,
  },
  rust = {
    filetypes = { 'rust' },
    parsers = { 'rust' },
    lsp_servers = { 'rust_analyzer', 'harper_ls' },
    formatters = { 'rust_analyzer' },
    dap = { 'codelldb' },
  },
  sass = {
    filetypes = { 'scss', 'sass' },
    parsers = { 'scss' },
    lsp_servers = { 'tailwindcss' },
    linters = { 'stylelint' },
    formatters = { 'prettier' },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.hexcolor.new({
          case = 'lower',
        }),
        augend.hexcolor.new({
          case = 'upper',
        }),
      }
    end,
  },
  solidity = {
    filetypes = { 'solidity' },
    parsers = { 'solidity' },
    lsp_servers = { 'solidity_ls' },
  },
  sql = {
    filetypes = { 'sql', 'mysql', 'plsql' },
    parsers = { 'sql' },
    linters = { 'sqlfluff' },
    formatters = {
      {
        'sqlfluff',
        opts = {
          args = { 'format', '--dialect=ansi', '-' },
        },
      },
    },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
  },
  typescript = {
    filetypes = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'javascript.jsx',
      'typescript.tsx',
    },
    parsers = { 'javascript' },
    lsp_servers = { 'vtsls', 'harper_ls' },
    linters = { 'biomejs' },
    formatters = { 'biome' },
    dap = { 'js-debug-adapter' },
    test = {
      'neotest-jest',
      'neotest-vitest',
      'neotest-playwright',
      'vim-test',
    },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.constant.new({
          elements = { 'let', 'const' },
          word = true,
          cyclic = true,
        }),
      }
    end,
    autopairs = function(filetypes, rule)
      return {
        -- Add parentheses in arrow function
        rule('=>', ' {  }', filetypes)
          :replace_endpair(function(opts)
            local prev_3char = opts.line:sub(opts.col - 3, opts.col - 2)
            local next_char = opts.line:sub(opts.col, opts.col)
            if prev_3char:match('%)$') then
              return '<BS><BS> => {  }' .. next_char
            end
            return ' {  }'
          end)
          :set_end_pair_length(2),
      }
    end,
  },
  vue = {
    filetypes = { 'vue' },
    parsers = { 'vue' },
    lsp_servers = { 'volar' },
  },
  ------------------------------------ {

  -- Tools & Markup {
  ansible = { -- See yaml
    filetypes = { 'yaml.ansible' },
    parsers = { 'yaml' },
    lsp_servers = { 'ansiblels' },
    linters = { 'ansible-lint', 'yq' },
  },
  beancount = {
    filetypes = { 'beancount' },
    parsers = { 'beancount' },
    lsp_servers = { 'beancount' },
    linters = { 'bean_check' },
    formatters = { 'bean-format' },
  },
  bicep = {
    filetypes = { 'bicep' },
    parsers = { 'bicep' },
    lsp_servers = { 'bicep' },
    formatters = { 'bicep' },
  },
  cmake = {
    filetypes = { 'cmake' },
    parsers = { 'cmake' },
    lsp_servers = { 'neocmake', 'harper_ls' },
    linters = { 'cmakelint' },
    formatters = { 'cmake_format' },
  },
  csv = {
    filetypes = { 'csv' },
    parsers = { 'csv' },
  },
  d2 = {
    filetypes = { 'd2' },
    parsers = {
      {
        'd2',
        install_info = {
          url = 'https://git.pleshevski.ru/pleshevskiy/tree-sitter-d2/',
          branch = 'main',
          files = { 'src/parser.c', 'src/scanner.cc' },
        },
      },
    },
    formatters = { 'd2' },
  },
  dbml = {
    filetypes = { 'dbml' },
    parsers = {
      {
        'dbml',
        install_info = {
          url = 'https://github.com/dynamotn/tree-sitter-dbml',
          branch = 'main',
          files = { 'src/parser.c' },
        },
      },
    },
  },
  dockerfile = {
    filetypes = { 'dockerfile' },
    parsers = { 'dockerfile' },
    lsp_servers = { 'dockerls' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
  },
  gitcommit = {
    filetypes = { 'gitcommit' },
    parsers = { 'gitcommit' },
    lsp_servers = { 'harper_ls' },
    linters = { 'gitlint' },
    null_ls = {
      { 'jira', type = 'completion', command = 'jira', custom = true },
    },
  },
  gitrebase = {
    filetypes = { 'gitrebase' },
    parsers = { 'girebase' },
    null_ls = {
      { 'gitrebase', type = 'code_actions', command = 'git' },
    },
  },
  gotmpl = {
    filetypes = { 'gotmpl' },
    parsers = { 'gotmpl' },
    autopairs = function(filetypes, rule)
      return {
        -- Add parentheses in function
        rule('{{', '  }', filetypes):set_end_pair_length(2),
        rule('{-', '{-  }', filetypes)
          :replace_endpair(function(_) return '<BS><BS>{{-  }' end)
          :set_end_pair_length(2),
      }
    end,
  },
  groovy = {
    filetypes = { 'groovy' },
    parsers = { 'groovy' },
    lsp_servers = { 'groovyls' },
    linters = { 'npm-groovy-lint' },
    formatters = { 'npm-groovy-lint' },
  },
  helm = { -- See gotmpl
    filetypes = { 'gotmpl' },
    parsers = { 'helm' },
    lsp_servers = { 'helm_ls' },
    linters = { 'trivy' },
    autopairs = function(filetypes, rule)
      return {
        -- Add parentheses in function
        rule('{{', '  }', filetypes):set_end_pair_length(2),
        rule('{-', '{-  }', filetypes)
          :replace_endpair(function(_) return '<BS><BS>{{-  }' end)
          :set_end_pair_length(2),
      }
    end,
  },
  hyprlang = {
    filetypes = { 'hyprlang' },
    parsers = { 'hyprlang' },
    lsp_servers = { 'hyprls' },
  },
  ini = {
    filetypes = { 'ini' },
    parsers = { 'ini' },
  },
  json = {
    filetypes = { 'json', 'jsonc', 'json5' },
    parsers = { 'json5' },
    lsp_servers = { 'jsonls' },
    linters = { 'yq', 'trivy' },
  },
  make = {
    filetypes = { 'config', 'automake', 'make' },
    parsers = { 'make' },
    lsp_servers = { 'autotools_ls' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
  },
  markdown = {
    filetypes = { 'markdown', 'markdown.mdx' },
    parsers = { 'markdown', 'markdown_inline' },
    lsp_servers = { 'marksman', 'vale_ls', 'harper_ls' },
    linters = { 'markdownlint-cli2' },
    formatters = {
      {
        'injected',
        opts = {
          lang_to_ft = {
            bash = 'sh',
          },
        },
        command = 'lua',
      },
      {
        'markdown-toc',
        opts = {
          condition = function(_, ctx)
            for _, line in
              ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false))
            do
              if line:find('<!%-%- toc %-%->') then return true end
            end
          end,
        },
      },
      {
        'markdownlint-cli2',
        opts = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(
              function(d) return d.source == 'markdownlint' end,
              vim.diagnostic.get(ctx.buf)
            )
            return #diag > 0
          end,
        },
      },
    },
    null_ls = {
      { 'jira', type = 'completion', command = 'jira', custom = true },
    },
    dial = function()
      local augend = require('dial.augend')
      return {
        augend.constant.new({
          elements = { '[ ]', '[x]' },
          word = false,
          cyclic = true,
        }),
        augend.misc.alias.markdown_header,
      }
    end,
    otter = true,
  },
  nginx = {
    filetypes = { 'nginx' },
    parsers = { 'nginx' },
    lsp_servers = { 'nginx_language_server' },
    formatters = { 'nginxfmt' },
  },
  nix = {
    filetypes = { 'nix' },
    parsers = { 'nix' },
    lsp_servers = { 'nil_ls', 'harper_ls' },
    linters = { 'nix' },
    formatters = { 'nixfmt' },
    null_ls = {
      { 'statix', type = 'code_actions', command = 'statix' },
    },
  },
  openapi = {
    filetypes = { 'yaml.openapi', 'json.openapi' },
    parsers = { 'yaml', 'json5' },
    lsp_servers = { 'vacuum' },
    linters = { 'yq' },
  },
  systemd = {
    filetypes = { 'systemd' },
    parsers = {},
    lsp_servers = { 'systemd-language-server' },
  },
  terraform = {
    filetypes = { 'tf', 'terraform', 'terraform-vars' },
    parsers = { 'hcl', 'terraform' },
    lsp_servers = { 'terraformls' },
    linters = { 'tflint', 'trivy' },
    formatters = { 'terraform_fmt' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
      { 'terraform_validate', type = 'diagnostics', command = 'terraform' },
    },
  },
  terragrunt = {
    filetypes = { 'terragrunt' },
    parsers = { 'hcl' },
    lsp_servers = { 'terraformls' },
    formatters = { 'terraform_fmt' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
      { 'terragrunt_validate', type = 'diagnostics', command = 'terragrunt' },
    },
  },
  toml = {
    filetypes = { 'toml' },
    parsers = { 'toml' },
    lsp_servers = { 'taplo', 'harper_ls' },
    formatters = { 'taplo' },
    otter = true,
  },
  treesitter = {
    filetypes = { 'scheme' },
    parsers = { 'query' },
    formatters = { 'format-queries' },
  },
  yaml = {
    filetypes = {
      'yaml',
      'yaml.gl-ci',
      'yaml.gh-action',
      'yaml.az-pl',
      'yaml.docker-compose',
    },
    parsers = { 'yaml' },
    lsp_servers = {
      'yamlls',
      'gitlab_ci_ls',
      'gh_actions_ls',
      'azure_pipelines_ls',
      'docker_compose_language_service',
    },
    linters = { 'yq', 'trivy' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
  },
  yuck = {
    filetypes = { 'yuck' },
    parsers = { 'yuck' },
  },
  ----------------- }
}
