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
  {
    -- Auto install tools
    'williamboman/mason.nvim',
    opts = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        for _, tool in ipairs(language.null_ls or {}) do
          local tool_package
          local is_mason_tool = true
          if type(tool) == 'string' then
            tool_package = tool
          elseif type(tool) == 'table' then
            if tool.mason then is_mason_tool = tool.mason.enabled ~= false end
            tool_package = tool.command
              or (tool.mason and tool.mason.package or tool[1])
          end
          if is_mason_tool then
            -- install server of language in bundle languages
            if
              vim.list_contains(_G.bundle_languages, name)
              or name == '*'
              or name == '_'
            then
              table.insert(opts.ensure_installed, tool_package)
            end
            -- lazy install server of language not in bundle languages
            if vim.list_contains(_G.enabled_languages, name) then
              vim.api.nvim_create_autocmd({ 'FileType' }, {
                pattern = language.filetypes,
                group = vim.api.nvim_create_augroup(
                  'mason_nullls_' .. name .. '_' .. tool_package,
                  {}
                ),
                callback = function()
                  local registry = require('mason-registry')
                  if not registry.is_installed(tool_package) then
                    vim.api.nvim_command('MasonInstall ' .. tool_package)
                  end
                end,
              })
            end
          end
        end
      end
    end,
  },
}
