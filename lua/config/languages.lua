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
  -- Programming language & Frameworks {
  angular = { -- See html and javascript
    filetypes = { 'htmlangular' },
    parsers = { 'angular' },
    lsp_servers = { 'angularls' },
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
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
    dap = { 'bash-debug-adapter' },
    test = { 'vim-test' },
    endwise = true,
  },
  cpp = {
    filetypes = { 'c', 'cpp' },
    parsers = { 'cpp' },
    lsp_servers = { 'clangd' },
    linters = { 'clang-tidy' },
    formatters = { 'clang-format' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
    dap = { 'codelldb' },
    test = {
      'neotest-gtest',
      'vim-test',
    },
  },
  c_sharp = {
    filetypes = { 'cs' },
    parsers = { 'c_sharp' },
    lsp_servers = { 'omnisharp' },
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
    -- formatters = { 'fish_indent' }, -- I don't want to use 4 spaces style of fish_indent
    endwise = true,
  },
  go = {
    filetypes = { 'go', 'gomod', 'gowork', 'gosum' },
    parsers = { 'go', 'gomod', 'gowork', 'gosum' },
    lsp_servers = { 'gopls' },
    formatters = { 'goimports', 'gofumpt' },
    null_ls = {
      { 'gomodifytags', type = 'code_actions', command = 'gomodifytags' },
      { 'impl', type = 'code_actions', command = 'impl' },
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
    dap = { 'delve' },
    test = { 'neotest-golang' },
  },
  html = {
    filetypes = { 'html' },
    parsers = { 'html' },
    lsp_servers = { 'emmet_ls', 'tailwindcss', 'html' },
    formatters = { 'html_beautify' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
  },
  java = {
    filetypes = { 'java' },
    parsers = { 'java' },
    lsp_servers = { 'jdtls' },
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
    lsp_servers = { 'lua_ls' },
    formatters = { 'stylua' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
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
    lsp_servers = { 'intelephense' },
    linters = { 'phpcs' },
    formatters = { 'php_cs_fixer' },
    dap = { 'php-debug-adapter' },
    test = { 'neotest-phpunit' },
  },
  python = {
    filetypes = { 'python' },
    parsers = { 'python' },
    lsp_servers = { 'pyright' },
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
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
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
    lsp_servers = { 'ruby_lsp' },
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
    lsp_servers = { 'rust_analyzer' },
    formatters = { 'rust_analyzer' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
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
    lsp_servers = { 'vtsls' },
    linters = { 'biomejs' },
    formatters = { 'biome' },
    dap = { 'js-debug-adapter' },
    test = {
      'neotest-jest',
      'neotest-vitest',
      'neotest-playwright',
      'vim-test',
    },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
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
    lsp_servers = { 'neocmake' },
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
    lsp_servers = { 'ltex' },
    linters = { 'gitlint' },
    null_ls = {
      { 'jira', type = 'completion', command = 'jira', custom = true },
      { 'dictionary', type = 'hover', command = 'curl' },
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
    linters = { 'yq' },
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
    lsp_servers = { 'marksman', 'ltex', 'vale_ls' },
    linters = { 'markdownlint-cli2' },
    formatters = {
      {
        'injected',
        opts = {
          lang_to_ft = {
            bash = 'sh',
          },
        },
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
      { 'dictionary', type = 'hover', command = 'curl' },
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
    lsp_servers = { 'nil_ls' },
    linters = { 'nix' },
    formatters = { 'nixfmt' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
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
    lsp_servers = { 'taplo' },
    formatters = { 'taplo' },
    null_ls = {
      { 'ltcc', type = 'code_actions', command = 'ltcc', custom = true },
      { 'ltcc', type = 'diagnostics', command = 'ltcc', custom = true },
    },
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
    linters = { 'yq' },
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
