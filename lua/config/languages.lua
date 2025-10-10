---@class DyLangSpec
---@field filetypes string[]
---@field parsers (string|DyParserSpec)[]
---@field lsp_servers? (string|DyLspSpec)[]
---@field linters? (string|DyLinterSpec)[]
---@field formatters? (string|DyFormatterSpec)[]
---@field null_ls? DyNullLsSpec[]
---@field dap? string[]
---@field test? string[]
---@field dial? fun(augend: Augend): Augend[]
---@field autopairs? fun(filetypes: string[], rule: Rule, cond: CondOpts, ts_cond: table): Rule[]
---@field endwise? boolean
---@field otter? boolean

---@class DyParserSpec
---@field [1] string
---@field install_info DyParserInstallSpec

---@class DyParserInstallSpec:InstallInfo
---@field url string
---@field branch? string

---@class DyLspSpec
---@field [1] string
---@field enabled? boolean|fun(filetype:string):boolean

---@class DyLinterSpec
---@field [1] string
---@field opts? table
---@field command? string
---@field mason? DyMasonSpec

---@class DyFormatterSpec
---@field [1] string
---@field opts? table
---@field command? string
---@field mason? DyMasonSpec

---@class DyNullLsSpec
---@field [1] string
---@field type string
---@field command string
---@field custom? boolean
---@field mason? DyMasonSpec

---@class DyMasonSpec
---@field enabled? boolean
---@field package string

---@alias DyLangRootSpec table<string,DyLangSpec>
---@type DyLangRootSpec

return {
  -- For all filetypes
  ['*'] = {
    filetypes = { '*' },
    parsers = {},
    lsp_servers = {
      {
        'sonarlint',
        enabled = vim.fn.executable('java') == 1,
      },
    },
    formatters = {
      { 'trim_whitespace', command = 'lua', mason = { enabled = false } },
      { 'trim_newlines', command = 'lua', mason = { enabled = false } },
      {
        'condense_blank_lines',
        command = 'sed',
        mason = { enabled = false },
      },
    },
    linters = { 'typos' },
    null_ls = {
      {
        'dictionary',
        type = 'hover',
        command = 'curl',
        mason = { enabled = false },
      },
      {
        'trail_space',
        type = 'diagnostics',
        command = 'lua',
        mason = { enabled = false },
      },
      {
        'gitsigns',
        type = 'code_actions',
        command = 'git',
        mason = { enabled = false },
      },
    },
    dial = function(augend)
      local logical_alias = augend.constant.new({
        elements = { '&&', '||' },
        word = false,
        cyclic = true,
      })

      local ordinal_numbers = augend.constant.new({
        elements = {
          'first',
          'second',
          'third',
          'fourth',
          'fifth',
          'sixth',
          'seventh',
          'eighth',
          'ninth',
          'tenth',
        },
        word = false,
        cyclic = true,
      })

      local weekdays = augend.constant.new({
        elements = {
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        },
        word = true,
        cyclic = true,
      })

      local months = augend.constant.new({
        elements = {
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        },
        word = true,
        cyclic = true,
      })

      local capitalized_boolean = augend.constant.new({
        elements = { 'True', 'False' },
        word = true,
        cyclic = true,
      })

      local log_level = augend.constant.new({
        elements = { 'trace', 'debug', 'info', 'warn', 'error', 'fatal' },
        word = true,
        cyclic = true,
      })

      return {
        augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.decimal_int, -- nonnegative and negative decimal number
        augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
        augend.date.alias['%Y/%m/%d'], -- date (2022/02/19, etc.)
        augend.date.alias['%d/%m/%Y'], -- date (19/02/2022, ...)
        capitalized_boolean,
        augend.constant.alias.bool, -- boolean value (true <-> false)
        augend.semver.alias.semver, -- semver
        ordinal_numbers,
        weekdays,
        months,
        logical_alias,
        log_level,
      }
    end,
    -- See rules API: https://github.com/windwp/nvim-autopairs/wiki/Rules-API
    autopairs = function(_, rule, cond, _)
      local languages_list = require('config.languages')
      local equal_rule_ignored_filetypes = function()
        local result = vim.list_extend({}, languages_list.bash.filetypes)
        result = vim.list_extend(result, languages_list.yaml.filetypes)
        result = vim.list_extend(result, languages_list.dockerfile.filetypes)
        result = vim.list_extend(result, { 'gitattributes' })
        for i, filetype in ipairs(result) do
          result[i] = '-' .. filetype
        end
        return result
      end

      return {
        -- Add spaces between parentheses
        rule(' ', ' ')
          :with_pair(cond.done())
          :replace_endpair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            if vim.tbl_contains({ '()', '{}', '[]' }, pair) then
              return ' ' -- it return space here
            end
            return '' -- return empty
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return vim.tbl_contains({ '(  )', '{  }', '[  ]' }, context)
          end),
        rule('', ' )')
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == ')' end)
          :with_cr(cond.none())
          :with_del(cond.none())
          :use_key(')'),
        rule('', ' }')
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == '}' end)
          :with_cr(cond.none())
          :with_del(cond.none())
          :use_key('}'),
        rule('', ' ]')
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == ']' end)
          :with_cr(cond.none())
          :with_del(cond.none())
          :use_key(']'),

        -- Add space after comma when have following text after comma
        rule(',', ' ')
          :replace_endpair(function(opts)
            local next_char = opts.line:sub(opts.col, opts.col)
            if next_char:match('%w$') then return ' ' end
            return ''
          end)
          :set_end_pair_length(0),

        -- Add space on equal sign
        rule('=', ' ', equal_rule_ignored_filetypes())
          :with_pair(cond.not_inside_quote())
          :with_pair(function(opts)
            local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
            if last_char:match('[%w%=%s]') then return true end
            return false
          end)
          :replace_endpair(function(opts)
            local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
            local next_char = opts.line:sub(opts.col, opts.col)
            next_char = next_char == ' ' and '' or ' '
            if prev_2char:match('%w$') then return '<BS> =' .. next_char end
            if prev_2char:match('%=$') then return next_char end
            if prev_2char:match('=') then return '<BS><BS>=' .. next_char end
            return ''
          end)
          :set_end_pair_length(0)
          :with_move(cond.none())
          :with_del(cond.none()),
      }
    end,
  },
  -- For only non-configured filetypes, effectively with
  -- `conform` and `nvim-lint` plugins
  ---@diagnostic disable-next-line: missing-fields
  ['_'] = {
    filetypes = { '_' },
    linters = {
      { 'compiler', command = 'lua', mason = { enabled = false } },
    },
  },

  -- Programming language & Frameworks {
  angular = { -- See `html` and `typescript`
    filetypes = { 'htmlangular' },
    parsers = { 'angular' },
    lsp_servers = { 'angularls', 'tailwindcss', 'harper_ls' },
    linters = {
      {
        'biomejs',
        command = 'biome',
        mason = { package = 'biome' },
      },
    },
    formatters = {
      'biome',
      { 'html_beautify', command = 'js-beautify' },
    },
  },
  arduino = { -- See `cpp`
    filetypes = { 'arduino' },
    parsers = { 'cpp' },
    lsp_servers = { 'arduino_language_server', 'harper_ls' },
    linters = { { 'clang-tidy', mason = { enabled = false } } },
    formatters = { 'clang-format' },
  },
  bash = {
    filetypes = {
      'sh',
      'bats',
      'sh.ebuild',
      'sh.PKGBUILD',
    },
    parsers = { 'bash' },
    lsp_servers = { 'bashls', 'termuxls', 'harper_ls' },
    -- linters = { 'shellcheck' }, # bashls cover it
    formatters = {
      'shellcheck',
      { 'shfmt', opts = { prepend_args = { '-i', '2', '-ci', '-bn', '-sr' } } },
    },
    null_ls = {
      {
        'shellcheck',
        type = 'code_actions',
        command = 'shellcheck',
        custom = true,
      },
    },
    dap = { 'bash' },
    test = { 'vim-test' },
    endwise = true,
  },
  cpp = {
    filetypes = { 'c', 'cpp' },
    parsers = { 'cpp' },
    lsp_servers = { 'clangd', 'harper_ls' },
    linters = { { 'clang-tidy', mason = { enabled = false } } },
    formatters = { 'clang-format' },
    dap = { 'codelldb' },
    test = { 'neotest-gtest', 'vim-test' },
  },
  c_sharp = {
    filetypes = { 'cs' },
    parsers = { 'c_sharp' },
    lsp_servers = { 'omnisharp', 'harper_ls' },
    formatters = {
      {
        'csharpier',
        command = 'dotnet',
        mason = { package = 'csharpier' },
      },
    },
    dap = { 'coreclr' },
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
    dial = function(augend)
      return {
        augend.hexcolor.new({ case = 'lower' }),
        augend.hexcolor.new({ case = 'upper' }),
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
        },
      },
    },
    lsp_servers = { 'cucumber_language_server' },
  },
  fish = {
    filetypes = { 'fish' },
    parsers = { 'fish' },
    lsp_servers = { 'fish_lsp' },
    linters = {
      { 'fish', mason = { enabled = false } },
    },
    endwise = true,
  },
  go = {
    filetypes = { 'go' },
    parsers = { 'go' },
    lsp_servers = { 'gopls', 'harper_ls' },
    formatters = { 'goimports', 'gofumpt' },
    null_ls = {
      { 'gomodifytags', type = 'code_actions', command = 'gomodifytags' },
      { 'impl', type = 'code_actions', command = 'impl' },
    },
    dap = { 'delve' },
    test = { 'neotest-golang' },
    linguist = { 'go' },
  },
  html = {
    filetypes = { 'html' },
    parsers = { 'html' },
    lsp_servers = { 'tailwindcss', 'html', 'harper_ls' },
    formatters = {
      { 'html_beautify', command = 'js-beautify' },
    },
  },
  java = {
    filetypes = { 'java' },
    parsers = { 'java' },
    lsp_servers = { 'jdtls', 'harper_ls' },
    dap = { 'javadbg' },
    test = { 'neotest-java' },
    dial = function(augend)
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
    lsp_servers = { 'ltex', 'texlab', 'vale_ls' },
    linters = { 'vale' },
    formatters = { 'tex-fmt' },
  },
  lua = {
    filetypes = { 'lua' },
    parsers = { 'lua' },
    lsp_servers = { 'lua_ls', 'harper_ls' },
    formatters = { 'stylua' },
    dial = function(augend)
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
    dap = { 'php' },
    test = { 'neotest-phpunit' },
  },
  python = {
    filetypes = { 'python' },
    parsers = { 'python' },
    lsp_servers = { 'pyright', 'ruff', 'harper_ls' },
    linters = { 'ruff' },
    formatters = {
      { 'ruff_fix', command = 'ruff' },
      { 'ruff_format', command = 'ruff' },
      { 'ruff_organize_imports', command = 'ruff' },
    },
    dap = { 'python' },
    test = { 'neotest-python' },
    dial = function(augend)
      return {
        augend.constant.new({
          elements = { 'and', 'or' },
          word = true,
          cyclic = true,
        }),
      }
    end,
  },
  rails = { -- See `ruby` and `html`
    filetypes = { 'eruby' },
    parsers = {
      {
        'embedded_template',
        install_info = {
          url = 'https://github.com/tree-sitter/tree-sitter-embedded-template',
        },
      },
    },
    lsp_servers = { 'ruby_lsp', 'tailwindcss', 'harper_ls' },
    linters = { 'erb_lint', 'html_beautify' },
    formatters = { 'erb_formatter' },
  },
  ruby = {
    filetypes = { 'ruby' },
    parsers = { 'ruby' },
    lsp_servers = { 'ruby_lsp', 'harper_ls' },
    linters = { 'rubocop' },
    formatters = { 'rubocop' },
    test = { 'neotest-rspec', 'vim-test' },
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
    dial = function(augend)
      return {
        augend.hexcolor.new({ case = 'lower' }),
        augend.hexcolor.new({ case = 'upper' }),
      }
    end,
  },
  solidity = {
    filetypes = { 'solidity' },
    parsers = { 'solidity' },
    lsp_servers = { 'solang' },
    formatters = { 'forge_fmt' },
  },
  sql = {
    filetypes = { 'sql', 'mysql', 'plsql' },
    parsers = { 'sql' },
    linters = { 'sqlfluff' },
    formatters = {
      { 'sqlfluff', opts = { args = { 'format', '--dialect=ansi', '-' } } },
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
    linters = {
      {
        'biomejs',
        command = 'biome',
        mason = { package = 'biome' },
      },
    },
    formatters = { 'biome' },
    dap = { 'js', 'firefox' },
    test = {
      'neotest-jest',
      'neotest-vitest',
      'neotest-playwright',
      'vim-test',
    },
    dial = function(augend)
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
  typst = {
    filetypes = { 'typst' },
    parsers = { 'typst' },
    lsp_servers = { 'tinymist' },
    formatters = { 'typstyle' },
  },
  vue = { -- See `html` and `typescript`
    filetypes = { 'vue' },
    parsers = { 'vue' },
    lsp_servers = { 'vue_ls', 'vtsls', 'tailwindcss', 'harper_ls' },
    dial = function(augend)
      return {
        augend.constant.new({
          elements = { 'let', 'const' },
          word = true,
          cyclic = true,
        }),
        augend.hexcolor.new({
          case = 'lower',
        }),
        augend.hexcolor.new({
          case = 'upper',
        }),
      }
    end,
  },
  zig = {
    filetypes = { 'zig' },
    parsers = { 'zig' },
    lsp_servers = { 'zls' },
  },
  ------------------------------------ {

  -- Tools & Markup {
  ansible = { -- See `yaml`
    filetypes = { 'yaml.ansible' },
    parsers = { 'yaml' },
    lsp_servers = { 'ansiblels' },
    linters = { 'ansible-lint', 'yamllint' },
  },
  awk = {
    filetypes = { 'awk' },
    parsers = {
      {
        'awk',
        install_info = {
          url = 'https://github.com/Beaglefoot/tree-sitter-awk',
        },
      },
    },
    lsp_servers = { 'awk_ls' },
    linters = { 'gawk' },
    formatters = { 'gawk' },
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
          url = 'https://github.com/madmaxieee/tree-sitter-d2',
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
        },
      },
    },
  },
  dockerfile = {
    filetypes = { 'dockerfile' },
    parsers = { 'dockerfile' },
    lsp_servers = { 'dockerls' },
    linters = { 'hadolint' },
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
      {
        'gitrebase',
        type = 'code_actions',
        command = 'git',
        mason = { enabled = false },
      },
    },
  },
  gomod = {
    filetypes = { 'gomod' },
    parsers = { 'gomod' },
  },
  gosum = {
    filetypes = { 'gosum' },
    parsers = { 'gosum' },
  },
  gotmpl = {
    filetypes = { 'gotmpl' },
    parsers = { 'gotmpl' },
    formatters = {
      -- { 'injected', command = 'lua', mason = { enabled = false } },
    },
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
  gowork = {
    filetypes = { 'gowork' },
    parsers = { 'gowork' },
  },
  groovy = {
    filetypes = { 'groovy' },
    parsers = { 'groovy' },
    lsp_servers = { 'groovyls' },
    linters = { 'npm-groovy-lint' },
    formatters = { 'npm-groovy-lint' },
  },
  helm = { -- See `gotmpl`
    filetypes = { 'helm', 'yaml.helm-values' },
    parsers = { 'helm' },
    lsp_servers = { 'helm_ls' },
    linters = { 'trivy' },
    formatters = {
      -- { 'injected', command = 'lua', mason = { enabled = false } },
    },
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
    linters = { 'jsonlint', 'trivy' },
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
    linters = { 'markdownlint-cli2', 'vale' },
    formatters = {
      -- { 'injected', command = 'lua', mason = { enabled = false } },
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
    dial = function(augend)
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
    linters = { 'nix', 'statix' },
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
    formatters = { 'yq' },
  },
  promql = {
    filetypes = { 'promql' },
    parsers = { 'promql' },
    lsp_servers = { 'promqlls' },
    linguist = { 'promql' },
  },
  systemd = {
    filetypes = { 'systemd' },
    parsers = {},
    lsp_servers = { 'systemd_ls' },
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
      {
        'terraform_validate',
        type = 'diagnostics',
        command = 'terraform',
        mason = { enabled = false },
      },
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
      {
        'terragrunt_validate',
        type = 'diagnostics',
        command = 'terragrunt',
        mason = { enabled = false },
      },
    },
  },
  toml = {
    filetypes = { 'toml' },
    parsers = { 'toml' },
    lsp_servers = { 'taplo', 'harper_ls' },
    formatters = {
      'taplo',
      -- { 'injected', command = 'lua', mason = { enabled = false } },
    },
    otter = true,
  },
  treesitter = {
    filetypes = { 'scheme' },
    parsers = { 'query' },
    formatters = { 'format-queries' },
  },
  xml = {
    filetypes = { 'xml' },
    parsers = { 'xml' },
  },
  yaml = {
    filetypes = {
      'yaml',
      'yaml.gitlab',
      'yaml.gh-action',
      'yaml.az-pl',
      'yaml.docker-compose',
      'yaml.helm-values',
    },
    parsers = { 'yaml' },
    lsp_servers = {
      'yamlls',
      {
        'gitlab_ci_ls',
        enabled = function(filetype) return filetype == 'yaml.gitlab' end,
      },
      {
        'gh_actions_ls',
        enabled = function(filetype) return filetype == 'yaml.gh-action' end,
      },
      {
        'azure_pipelines_ls',
        enabled = function(filetype) return filetype == 'yaml.az-pl' end,
      },
      {
        'docker_compose_language_service',
        enabled = function(filetype) return filetype == 'yaml.docker-compose' end,
      },
    },
    linters = { 'yamllint', 'trivy' },
    formatters = {
      'yamlfmt',
      -- { 'injected', command = 'lua', mason = { enabled = false } },
    },
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
