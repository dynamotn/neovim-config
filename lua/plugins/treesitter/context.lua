return {
  {
    -- Show code context
    'nvim-treesitter/nvim-treesitter-context',
    event = 'LazyFile',
    keys = {
      {
        'gC',
        function() require('treesitter-context').go_to_context(vim.v.count1) end,
        desc = 'Go to Context',
      },
    },
    opts = function()
      local tsc = require('treesitter-context')
      Snacks.toggle({
        name = 'Treesitter Context',
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map('<leader>ut')
      return { mode = 'cursor', max_lines = 3 }
    end,
  },
}
