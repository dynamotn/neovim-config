---@diagnostic disable-next-line: unused-local
local language = require('config.languages').cmake

return vim.list_contains(_G.enabled_languages, 'cmake')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            neocmake = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Powerful toolbox for CMake
        'Civitasv/cmake-tools.nvim',
        init = function()
          local loaded = false
          local function check()
            local cwd = vim.uv.cwd()
            if vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
              require('lazy').load({ plugins = { 'cmake-tools.nvim' } })
              loaded = true
            end
          end
          check()
          vim.api.nvim_create_autocmd('DirChanged', {
            callback = function()
              if not loaded then check() end
            end,
          })
        end,
        opts = {},
      },
    }
  or {}
