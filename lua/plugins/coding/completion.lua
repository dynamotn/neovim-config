return {
  {
    'saghen/blink.cmp',
    dependencies = { 'onsails/lspkind.nvim' },
    opts = {
      signature = { enabled = true },
      completion = {
        menu = {
          draw = {
            columns = { { 'kind_icon', 'source_name', gap = 1 }, { 'label', 'label_description', gap = 1 } },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local icon = ctx.kind_icon
                  -- Show icon of file when source is Path
                  if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                    local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then
                      icon = dev_icon
                    end
                  elseif vim.tbl_contains({ 'codeium' }, ctx.source_name) then
                    icon = require('config.defaults').icons.kinds.Codeium
                  else
                    icon = require('lspkind').symbolic(ctx.kind, {
                      mode = 'symbol',
                    })
                  end

                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from nvim-web-devicons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  local hl = 'BlinkCmpKind' .. ctx.kind
                    or require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx)
                  if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                    local dev_icon, dev_hl = require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end,
              },
              source_name = {
                text = function(ctx)
                  if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                    return _G.completion_sources['Path']
                  end
                  return _G.completion_sources[ctx.source_name] or ctx.source_name
                end,
              },
            },
          },
        },
      },
    },
  },
}
