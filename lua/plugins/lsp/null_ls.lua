return {
  -- Use null-ls for formatting/diagnostics with some none-LSP tools
  { import = 'lazyvim.plugins.extras.lsp.none-ls' },
  {
    'nvimtools/none-ls.nvim',
    -- I don't want to use default LazyVim sources
    config = function(_, opts)
      local null_ls = require('null-ls')
      opts.root_dir = opts.root_dir
        or require('null-ls.utils').root_pattern('Makefile', '.git')
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

      -- null-ls answers `supports_method` from the filetype of the current
      -- buffer and ignores the buffer it is asked about. Otter forwards
      -- requests from a markdown buffer to its hidden `.otter.py` buffer, so
      -- null-ls claimed completion there on the strength of the markdown
      -- `jira` source, answered first with no items, and that empty list
      -- won over the real language server's
      local on_init = opts.on_init
      opts.on_init = function(client, initialize_result)
        local supports_method = client.supports_method
        client.supports_method = function(self, method, bufnr)
          if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
          if
            bufnr
            and bufnr ~= 0
            and bufnr ~= vim.api.nvim_get_current_buf()
            and vim.api.nvim_buf_is_loaded(bufnr)
          then
            return vim.api.nvim_buf_call(
              bufnr,
              function() return supports_method(self, method) end
            )
          end
          return supports_method(self, method)
        end
        if on_init then on_init(client, initialize_result) end
      end
      null_ls.setup(opts)
    end,
  },
  {
    -- Auto install tools
    'mason-org/mason.nvim',
    opts = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        for _, tool in ipairs(language.null_ls or {}) do
          local tool_package = require('util.languages').get_mason_package(tool)
          local is_mason_tool = true
          if type(tool) == 'table' and tool.mason then
            is_mason_tool = tool.mason.enabled ~= false
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
                  require('util.lazy_install').install_once(tool_package)
                end,
              })
            end
          end
        end
      end
    end,
  },
}
