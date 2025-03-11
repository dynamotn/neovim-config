return {
  -- Use null-ls for formatting/diagnostics with some none-LSP tools
  { import = 'lazyvim.plugins.extras.lsp.none-ls' },
  {
    'nvimtools/none-ls.nvim',
    -- I don't want to use default LazyVim sources
    config = function(_, opts)
      local null_ls = require('null-ls')
      opts.root_dir = opts.root_dir
        or require('null-ls.utils').root_pattern(
          '.neoconf.json',
          'Makefile',
          '.git'
        )
      opts.sources = {}

      -- Default sources
      table.insert(opts.sources, null_ls.builtins.diagnostics.trail_space)
      table.insert(opts.sources, null_ls.builtins.code_actions.gitsigns)

      -- Unified null_ls source configs
      local languages_list = vim.tbl_filter(
        function(language) return language.null_ls end,
        require('config.languages')
      )
      local source_configs = {}
      local filetypes = {}
      for _, language in ipairs(languages_list) do
        for _, tool in ipairs(language.null_ls) do
          local tool_name = tool[1]
          local key = tool.type .. '.' .. tool_name
          if source_configs[key] then
            source_configs[key].filetypes =
              vim.list_extend(filetypes[key], language.filetypes)
          else
            source_configs[key] = {
              info = tool,
              filetypes = vim.deepcopy(language.filetypes),
            }
            filetypes[key] = vim.list_slice(language.filetypes)
          end
        end
      end

      -- Setup null_ls configs with predefined filetypes
      for _, config in pairs(source_configs) do
        table.insert(
          opts.sources,
          require(
            (config.info.custom and 'tools.' or 'null-ls.builtins.')
              .. config.info.type
              .. '.'
              .. config.info[1]
          ).with({
            filetypes = config.filetypes,
          })
        )
      end
      null_ls.setup(opts)
    end,
  },
}
