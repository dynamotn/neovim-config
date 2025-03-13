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

      -- Unified null_ls source configs
      local source_configs = {}
      for name, language in pairs(require('config.languages')) do
        for _, tool in ipairs(language.null_ls or {}) do
          local tool_name = tool[1]
          local key = tool.type .. '.' .. tool_name
          if source_configs[key] then
            source_configs[key].filetypes =
              vim.list_extend(source_configs[key].filetypes, language.filetypes)
          else
            source_configs[key] = {
              info = tool,
              filetypes = name == '*' and {}
                or vim.deepcopy(language.filetypes),
            }
          end
        end
      end

      -- Setup null_ls configs with predefined file types
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
