return {
  {
    -- AI Engine (Codeium) for coding
    'Exafunction/codeium.nvim',
    cmd = 'Codeium',
    event = 'InsertEnter',
    enabled = _G.used_full_plugins or _G.enabled_plugins.codeium,
    build = function()
      require('lazy').load({ plugins = { 'codeium.nvim' }, wait = true })
      vim.cmd(':Codeium Auth')
    end,
    opts = function(_)
      ---@diagnostic disable-next-line: duplicate-set-field
      LazyVim.cmp.actions.ai_accept = function()
        if require('codeium.virtual_text').get_current_completion_item() then
          LazyVim.create_undo()
          vim.api.nvim_input(require('codeium.virtual_text').accept())
          return true
        end
      end

      return {
        enable_cmp_source = true,
        virtual_text = {
          enabled = false,
          key_bindings = {
            accept = false,
            next = '<M-]>',
            prev = '<M-[>',
          },
        },
      }
    end,
  },
  {
    -- AI Engine (Github Copilot) for coding
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    enabled = _G.used_full_plugins or _G.enabled_plugins.copilot,
    event = 'BufReadPost',
    build = function()
      require('lazy').load({ plugins = { 'copilot.lua' }, wait = true })
      vim.cmd(':Copilot auth')
    end,
    opts = function(_)
      ---@diagnostic disable-next-line: duplicate-set-field
      LazyVim.cmp.actions.ai_accept = function()
        if require('copilot.suggestion').is_visible() then
          LazyVim.create_undo()
          require('copilot.suggestion').accept()
          return true
        end
      end
      return {
        suggestion = {
          enabled = false,
          auto_trigger = true,
          hide_during_completion = true,
          keymap = {
            accept = false,
            next = '<M-]>',
            prev = '<M-[>',
          },
        },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
        },
        disable_limit_reached_message = true,
      }
    end,
  },
  {
    -- AI Chat
    'olimorris/codecompanion.nvim',
    cmd = { 'CodeCompanion', 'CodeCompanionChat' },
    init = function()
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        CodeCompanion = '「AI」',
      })
    end,
    opts = {
      strategies = {
        chat = {
          adapter = vim.env.VIM_COMPANION_ADAPTER
            or _G.companion_adapter
            or 'ollama',
        },
        inline = {
          adapter = vim.env.VIM_COMPANION_ADAPTER
            or _G.companion_adapter
            or 'ollama',
        },
      },
    },
  },
  -- Vibe Coding
  { import = 'lazyvim.plugins.extras.ai.avante' },
  {
    -- Edgy integration
    'folke/edgy.nvim',
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = 'codecompanion',
        title = 'CodeCompanion Chat',
        size = { width = 80 },
      })
    end,
  },
  {
    -- Lualine integration
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.cmp_source('codeium')
      )
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          local clients = package.loaded['copilot']
              and vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })
            or {}
          if #clients > 0 then
            local status = require('copilot.status').data.status
            return (status == 'InProgress' and 'pending')
              or (status == 'Warning' and 'error')
              or 'ok'
          end
        end)
      )
    end,
  },
  {
    -- Completion with Codeium
    'saghen/blink.cmp',
    dependencies = {
      {
        'codeium.nvim',
        enabled = _G.used_full_plugins or _G.enabled_plugins.codeium,
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              codeium = '「AI」',
            })
        end,
      },
    },
    opts = {
      sources = {
        compat = { 'codeium' },
        providers = {
          codeium = {
            kind = 'Codeium',
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
  {
    -- Completion with Copilot
    'saghen/blink.cmp',
    dependencies = {
      {
        'giuxtaposition/blink-cmp-copilot',
        enabled = _G.used_full_plugins or _G.enabled_plugins.copilot,
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              copilot = '「AI」',
            })
        end,
      },
    },
    opts = {
      sources = {
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            kind = 'Copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}
