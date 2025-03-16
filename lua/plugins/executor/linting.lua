return {
  {
    -- Linters
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        for _, ft in ipairs(language.filetypes) do
          opts.linters_by_ft[ft] = {}
          for _, tool in ipairs(language.linters or {}) do
            local tool_name, tool_command
            -- Add linter's config to list of tools if exist
            if type(tool) == 'string' then
              tool_name = tool
              tool_command = tool
            elseif type(tool) == 'table' then
              tool_name = tool[1]
              tool_command = tool.command or tool_name
              if vim.fn.executable(tool_command) == 1 or name == '*' then
                opts.linters[tool_name] = tool.opts
              end
            end
            if vim.fn.executable(tool_command) == 1 or name == '*' then
              table.insert(opts.linters_by_ft[ft], tool_name)
            end
          end
        end
      end
    end,
  },
  {
    -- Auto install linters
    'williamboman/mason.nvim',
    opts = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        for _, tool in ipairs(language.linters or {}) do
          local tool_name, tool_command, is_mason_tool
          if type(tool) == 'string' then
            tool_name = tool
            tool_command = tool
            is_mason_tool = true
          elseif type(tool) == 'table' then
            tool_name = tool[1]
            tool_command = tool.command or tool_name
            is_mason_tool = tool.is_mason_tool
          end
          if is_mason_tool then
            -- install server of language in bundle languages
            if
              vim.list_contains(_G.bundle_languages, name)
              or name == '*'
              or name == '_'
            then
              table.insert(opts.ensure_installed, tool_command)
            end
            -- lazy install server of language not in bundle languages
            if vim.list_contains(_G.enabled_languages, name) then
              vim.api.nvim_create_autocmd({ 'FileType' }, {
                pattern = language.filetypes,
                group = vim.api.nvim_create_augroup(
                  'mason_linter_' .. tool_command,
                  {}
                ),
                callback = function()
                  local registry = require('mason-registry')
                  if not registry.is_installed(tool_command) then
                    vim.api.nvim_command('MasonInstall ' .. tool_command)
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
