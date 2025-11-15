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
              if tool.opts then
                opts.linters[tool_name] = vim.tbl_extend(
                  'force',
                  opts.linters[tool_name] or {},
                  tool.opts
                )
              end
            end
            if
              (vim.fn.executable(tool_command) == 1 or name == '*')
              and tool_name ~= 'vale'
            then
              table.insert(opts.linters_by_ft[ft], tool_name)
            end
          end
        end
      end

      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require('lint').try_lint()
          if vim.fn.filereadable('.vale.ini') > 0 then
            require('lint').try_lint({ 'vale' })
          end
        end,
      })
    end,
  },
  {
    -- Auto install linters
    'mason-org/mason.nvim',
    opts = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        for _, tool in ipairs(language.linters or {}) do
          local tool_package
          local is_mason_tool = true
          if type(tool) == 'string' then
            tool_package = tool
          elseif type(tool) == 'table' then
            if tool.mason then is_mason_tool = tool.mason.enabled ~= false end
            tool_package = tool.mason and tool.mason.package or tool[1]
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
                  'mason_linter_' .. name .. '_' .. tool_package,
                  {}
                ),
                callback = function()
                  if
                    not require('mason-registry').is_installed(tool_package)
                  then
                    require('mason.api.command').MasonInstall({ tool_package })
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
