local cmp_util = require('util.cmp')

return {
  {
    -- Copilot with native LSP
    import = 'lazyvim.plugins.extras.ai.copilot-native',
    enabled = vim.fn.has('nvim-0.12.0') == 1,
  },
  {
    -- AI CLI
    import = 'lazyvim.plugins.extras.ai.sidekick',
  },
  {
    -- LLMs & Agents
    'olimorris/codecompanion.nvim',
    cmd = {
      'CodeCompanion',
      'CodeCompanionChat',
      'CodeCompanionCLI',
      'CodeCompanionCmd',
      'CodeCompanionActions',
      'CodeCompanionHistory',
      'CodeCompanionSummaries',
    },
    dependencies = {
      'nvim-treesitter',
      'ravitemer/mcphub.nvim', -- MCP Hub
      'ravitemer/codecompanion-history.nvim', -- History
      'Davidyz/VectorCode', -- Indexing
    },
    init = function()
      _G.completion_sources =
        vim.tbl_extend('force', _G.completion_sources or {}, {
          CodeCompanion = '「AI」',
        })
    end,
    opts = {
      interactions = {
        chat = {
          adapter = vim.env.VIM_COMPANION_CHAT_ADAPTER or 'copilot',
          model = vim.env.VIM_COMPANION_CHAT_MODEL or 'claude-sonnet-4.6',
          roles = {
            llm = require('config.defaults').icons.kinds.CodeCompanion
              .. ' LLM',
            user = require('config.defaults').icons.me .. ' Dynamo',
          },
          keymaps = {
            send = {
              modes = { n = '<CR>', i = '<C-s>' },
              index = 1,
              callback = 'keymaps.send',
              description = 'Send message',
            },
            stop = {
              modes = { n = '<C-c>' },
              index = 2,
              callback = 'keymaps.stop',
              description = 'Stop generation',
            },
            clear = {
              modes = { n = 'gc' },
              index = 3,
              callback = 'keymaps.clear',
              description = 'Clear chat',
            },
          },
          slash_commands = {
            image = {
              opts = {
                dirs = {
                  '~/Multimedia/Pictures/',
                },
              },
            },
          },
          tools = {
            cmd_runner = {
              opts = {
                require_approval_before = true,
              },
            },
            delete_file = {
              opts = {
                require_approval_before = true,
              },
            },
            groups = {
              read_only = {
                description = 'Read-only tools for searching and reading files',
                tools = {
                  'file_search',
                  'get_changed_files',
                  'grep_search',
                  'read_file',
                },
                prompt = 'You have access to read-only tools: ${tools}',
              },
            },
          },
        },
        inline = {
          adapter = vim.env.VIM_COMPANION_INLINE_ADAPTER or 'copilot',
          model = vim.env.VIM_COMPANION_INLINE_MODEL or 'claude-sonnet-4.6',
          keymaps = {
            accept = {
              modes = { n = 'ga' },
              index = 1,
              callback = 'keymaps.accept',
              description = 'Accept change',
            },
            reject = {
              modes = { n = 'gr' },
              index = 2,
              callback = 'keymaps.reject',
              description = 'Reject change',
            },
          },
        },
        cli = {
          agent = vim.env.VIM_COMPANION_CLI_AGENT or 'copilot',
          agents = {
            claude = {
              cmd = 'claude',
              args = {},
              description = 'Claude Code CLI',
              provider = 'terminal',
            },
            gemini = {
              cmd = 'gemini',
              args = {},
              description = 'Gemini CLI',
              provider = 'terminal',
            },
            copilot = {
              cmd = 'copilot',
              args = {},
              description = 'Github Copilot CLI',
              provider = 'terminal',
            },
          },
        },
        cmd = {
          adapter = vim.env.VIM_COMPANION_CMD_ADAPTER or 'copilot',
        },
        background = {
          adapter = {
            name = vim.env.VIM_COMPANION_BACKGROUND_ADAPTER or 'ollama',
            model = vim.env.VIM_COMPANION_BACKGROUND_MODEL
              or 'qwen-7b-instruct',
          },
        },
      },
      opts = {
        log_level = 'DEBUG',
      },
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
        history = {
          opts = {
            dir_to_save = vim.fn.stdpath('data') .. '/codecompanion_chats.json',
          },
        },
        vectorcode = {
          opts = {
            add_tool = true,
            add_slash_command = true,
          },
          tool_opts = nil,
        },
      },
    },
    keys = {
      {
        '<leader>ac',
        function() require('codecompanion').chat() end,
        desc = 'CodeCompanion Toggle Chat',
      },
      {
        'ga',
        '<cmd>CodeCompanionChat Add<cr>',
        mode = { 'v' },
        desc = 'Add Selection to Chat',
      },
      {
        '<leader>aC',
        '<cmd>CodeCompanionActions<cr>',
        desc = 'CodeCompanion Actions',
      },
      {
        '<leader>aI',
        '<cmd>CodeCompanion<cr>',
        desc = 'CodeCompanion Inline Chat',
      },
    },
  },
  {
    -- Edgy integration for AI tools
    'folke/edgy.nvim',
    opts = function(_, opts)
      opts.bottom = opts.bottom or {}
      table.insert(opts.bottom, {
        name = 'Code Companion',
        ft = 'codecompanion',
        size = { height = 0.4 },
        on_enter = function() vim.cmd('CodeCompanionChat') end,
      })
      return opts
    end,
  },
  {
    -- MCP Hub integration for AI tools
    'ravitemer/mcphub.nvim',
    enabled = vim.fn.executable('npm') == 1,
    build = vim.fn.executable('mise') == 1 and 'mise use -g npm:mcp-hub@latest'
      or 'npm install -g mcp-hub@latest',
    opts = {
      auto_approve = true,
      auto_toggle_mcp_servers = false,
      ui = {
        window = {
          border = vim.o.winborder,
        },
      },
    },
    keys = {
      {
        '<leader>M',
        '<cmd>MCPHub<CR>',
        desc = 'MCPHub',
      },
    },
  },
  {
    -- Repository indexing tool for LLMs
    'Davidyz/VectorCode',
    version = '*',
    enabled = vim.fn.executable('vectorcode') == 1,
    build = 'uv tool upgrade vectorcode',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      async_backend = 'lsp',
    },
  },
}
