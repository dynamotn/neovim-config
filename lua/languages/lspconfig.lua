local M = {}

M.lua_ls = function(default_opts)
  local opts = default_opts
  opts.settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'awesome' },
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = false,
        defaultConfig = {
          indent_style = 'space',
          indent_size = '2',
        },
      },
      hint = {
        enable = true,
      },
      completion = {
        callSnippet = 'Replace',
      },
    },
  }
  return opts
end

M.yamlls = function(default_opts)
  local opts = default_opts
  opts.settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      validate = true,
      format = {
        enable = true,
      },
      hover = true,
      schemaStore = {
        enable = true,
        url = 'https://www.schemastore.org/api/json/catalog.json',
      },
      schemaDownload = {
        enable = true,
      },
      schemas = {},
      trace = { server = 'debug' },
    },
  }
  return opts
end

M.sqls = function(default_opts)
  local opts = vim.deepcopy(default_opts)

  opts.on_attach = function(client, buffer)
    default_opts.on_attach(client, buffer)

    local present, sqls = pcall(require, 'sqls')
    if present then
      sqls.on_attach(client, buffer)
      vim.api.nvim_buf_create_user_command(buffer, 'SqlsEditConnections', 'split ~/.config/sqls/config.yml', {})
    end
  end

  return opts
end

M.gopls = function(default_opts)
  local opts = default_opts

  opts.settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  }

  return opts
end

M.jsonls = function(default_opts)
  local opts = default_opts

  opts.settings = {
    json = {
      format = {
        enable = true,
      },
      validate = { enable = true },
    },
  }

  return opts
end

return M
