local extension_dir = vim.fn.stdpath('data')
  .. '/mason/packages/sonarlint-language-server/extension/analyzers'
local token_path = vim.fn.stdpath('data') .. '/sonarlint/tokens'
vim.fn.mkdir(token_path, 'p')

local did_change_configuration = function(client, settings)
  if not client then return end
  client.notify('workspace/didChangeConfiguration', {
    settings = settings,
  })
end

local get_token = function(token_name)
  local path = token_path .. '/' .. token_name
  if vim.fn.filereadable(path) == 1 then
    return vim.fn.readfile(path)[1]
  else
    return nil
  end
end

local input_token = function(token_name)
  local token = vim.fn.input(
    'Enter your Sonarlint token for ' .. token_name .. ' organization'
  )
  if token == nil or #token == 0 then
    vim.notify('Token not found.', vim.log.levels.ERROR)
    return
  end
  vim.fn.writefile({ token }, token_path .. '/' .. token_name)
end

local cmd = {
  'sonarlint-language-server',
  '-stdio',
}

if
  (vim.uv or vim.loop).fs_stat(extension_dir) and LazyVim.has('mason.nvim')
then
  cmd = vim.list_extend(cmd, {
    '-analyzers',
    extension_dir .. '/analyzers/csharpenterprise.jar',
    extension_dir .. '/analyzers/sonarcsharp.jar',
    extension_dir .. '/analyzers/sonargo.jar',
    extension_dir .. '/analyzers/sonarhtml.jar',
    extension_dir .. '/analyzers/sonariac.jar',
    extension_dir .. '/analyzers/sonarjava.jar',
    extension_dir .. '/analyzers/sonarjavasymbolicexecution.jar',
    extension_dir .. '/analyzers/sonarjs.jar',
    extension_dir .. '/analyzers/sonarlintomnisharp.jar',
    extension_dir .. '/analyzers/sonarphp.jar',
    extension_dir .. '/analyzers/sonarpython.jar',
    extension_dir .. '/analyzers/sonartext.jar',
    extension_dir .. '/analyzers/sonarxml.jar',
  })
end

return {
  cmd = cmd,
  filetypes = {
    'cs',
    'go',
    'gomod',
    'gowork',
    'gotmpl',
    'html',
    'templ',
    'dockerfile',
    'hcl',
    'terraform',
    'tf',
    'terraform-vars',
    'yaml',
    'yml',
    'json',
    'java',
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'php',
    'python',
    'text',
    'plaintex',
    'tex',
    'org',
    'markdown',
    'xml',
    'xsd',
    'xsl',
    'xslt',
    'svg',
  },
  root_markers = { '.git', '.neoconf.json', 'sonar-project.properties' },
  init_options = {
    sonarlint = {
      rules = vim.empty_dict(),
      connectedMode = {
        connections = {
          sonarqube = {
            {
              connectionId = '',
              serverUrl = '',
              token = '',
              disableNotifications = false,
            },
          },
          sonarcloud = {
            {
              connectionId = '',
              region = 'EU', -- or US
              organizationKey = '',
              token = '',
              disableNotifications = false,
            },
          },
        },
        project = {
          connectionId = '',
          projectKey = '',
        },
      },
      disableTelemetry = true,
      focusOnNewCode = false,
    },
  },
  handlers = {
    ['sonarlint/canShowMissingRequirementsNotification'] = function()
      return true
    end,
    ['sonarlint/isOpenInEditor'] = function(_, _, _) return true end,
    ['sonarlint/isIgnoredByScm'] = function(_, file_uri, _)
      local output =
        vim.fn.system('git check-ignore ' .. vim.uri_from_fname(file_uri))
      if
        vim.v.shell_error == 128
        or (vim.v.shell_error ~= 128 and output == '')
      then
        return false
      else
        return true
      end
    end,
    ['sonarlint/listFilesInFolder'] = function(_, params, _, _)
      local folder = vim.uri_to_fname(params.folderUri)
      local files = vim.fs.dir(folder)

      local result = {
        foundFiles = {},
      }

      for path, t in files do
        if t == 'file' then
          table.insert(
            result.foundFiles,
            { fileName = path, filePath = folder }
          )
        end
      end

      return result
    end,
    ['sonarlint/filterOutExcludedFiles'] = function(_, params, _, _)
      return params
    end,
    ['sonarlint/showRuleDescription'] = function(_, req, _, _)
      local uri =
        'https://next.sonarqube.com/sonarqube/coding_rules?q=%s&open=%s'
      vim.ui.open(string.format(uri, req.key, req.key))
    end,
    ['sonarlint/needCompilationDatabase'] = function(_, _, ctx)
      local locations = vim.fs.find('compile_commands.json', {
        upward = true,
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      })
      if #locations > 0 then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        did_change_configuration(client, {
          sonarlint = {
            pathToCompileCommands = locations[1],
          },
        })
      else
        vim.notify_once(
          "Couldn't find compile_commands.json. Make sure it exists in a parent directory.",
          vim.log.levels.ERROR
        )
      end
    end,
    ['sonarlint/listAllRules'] = function(err, result)
      if err then
        vim.notify(
          'Cannot request the list of rules: ' .. err,
          vim.log.levels.ERROR
        )
        return
      end
      local buf = vim.api.nvim_create_buf(false, true)
      for language, rules in pairs(result) do
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '# ' .. language, '' })
        for _, rule in ipairs(rules) do
          local line = { ' - ', rule.key, ': ', rule.name }
          if rule.activeByDefault then
            line[#line + 1] = ' (active by default)'
          end
          vim.api.nvim_buf_set_lines(
            buf,
            -1,
            -1,
            false,
            { table.concat(line, '') }
          )
        end
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '' })
      end
      vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
      vim.api.nvim_set_option_value('readonly', true, { buf = buf })
      vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
      vim.keymap.set(
        'n',
        'q',
        '<cmd>close<cr>',
        { buffer = buf, silent = true }
      )
      vim.cmd('vsplit')
      local win = vim.api.nvim_get_current_win()

      vim.api.nvim_win_set_buf(win, buf)
    end,
    ['sonarlint/getTokenForServer'] = function(_, org, _)
      local token_name = 'neovim'
      if org ~= nil and #org > 0 then token_name = org[1] end
      local token = get_token(token_name)

      -- If the token is not found, ask for user input
      if token == nil then
        input_token(token_name)
        token = get_token(token_name)
      end
      -- if the token is still not found, there's been an error
      if token == nil then
        vim.notify('Token not found.', vim.log.levels.ERROR)
        return
      end
      return token
    end,
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'SonarlintDeactivateRule',
      function(rule)
        did_change_configuration(client, {
          sonarlint = {
            rules = {
              [rule] = { level = 'off' },
            },
          },
        })
      end,
      {
        desc = 'Deactivate a Sonarlint rule',
        nargs = 1,
      }
    )
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'SonarlintToken',
      function(opts) input_token(opts.args) end,
      {
        desc = 'Input Sonarlint token for the organization / cloud',
        nargs = 1,
      }
    )
  end,
}
