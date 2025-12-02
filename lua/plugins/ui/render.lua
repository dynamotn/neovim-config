local languages_list = require('config.languages')
local diagram_filetypes = {}
vim.list_extend(diagram_filetypes, languages_list.markdown.filetypes)
vim.list_extend(diagram_filetypes, languages_list.d2.filetypes)
return {
  {
    -- Render diagram as code
    'dynamotn/diagram.nvim',
    ft = diagram_filetypes,
    dependencies = {
      '3rd/image.nvim',
      ft = diagram_filetypes,
      opts = {
        backend = vim.env.ZELLIJ ~= nil and 'ueberzug' or 'kitty',
        max_height_window_percentage = 90,
        max_width_window_percentage = 90,
        integrations = {
          markdown = {
            resolve_image_path = function(document_path, image_path, fallback)
              -- Format image path for Obsidian notes
              for _, path in ipairs(_G.obsidian.vaults()) do
                if document_path:find(path.path, 1, true) then
                  return path.path .. '/' .. image_path
                end
              end
              return fallback(document_path, image_path)
            end,
          },
        },
      },
    },
    opts = {
      events = {
        render_buffer = {
          'BufWritePost',
          'TextChanged',
          'BufWinEnter',
          'InsertLeave',
          'CursorMoved',
        },
        clear_buffer = { 'BufLeave', 'BufWinLeave' },
      },
      renderer_options = {
        d2 = {
          theme_id = 4,
          dark_theme_id = 4,
          layout = 'tala',
        },
      },
    },
    config = function(_, opts)
      require('diagram').setup(vim.tbl_extend('force', {
        integrations = {
          require('diagram.integrations.markdown'),
          require('tools.diagram.d2.integration'),
        },
      }, opts))
    end,
    enabled = (_G.used_full_plugins or vim.fn.executable('magick') == 1),
    cond = vim.env.ZELLIJ == nil or vim.fn.executable('ueberzug') == 1,
  },
  {
    -- Render images in a file
    'folke/snacks.nvim',
    opts = {
      image = {
        enabled = true,
      },
    },
  },
}
