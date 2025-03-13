return {
  {
    -- Formatters
    'stevearc/conform.nvim',
    opts = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        for _, ft in ipairs(language.filetypes) do
          opts.formatters_by_ft[ft] = {}
          for _, tool in ipairs(language.formatters or {}) do
            -- Add formatter's config to list of tools if exist
            if type(tool) == 'string' then
              if vim.fn.executable(tool) == 1 or name == '*' then
                table.insert(opts.formatters_by_ft[ft], tool)
              end
            elseif type(tool) == 'table' then
              local tool_name = tool[1]
              if vim.fn.executable(tool_name) == 1 then
                opts.formatters[tool_name] = tool.opts
                table.insert(opts.formatters_by_ft[ft], tool_name)
              end
            end
          end
        end
      end
    end,
  },
}
