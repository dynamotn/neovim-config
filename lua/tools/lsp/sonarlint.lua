local util = require('lspconfig.util')
local extension_dir = vim.fn.stdpath('data')
  .. '/mason/packages/sonarlint-language-server/extension/analyzers'

local did_change_configuration = function(client, settings)
  if not client then return end
  client.notify('workspace/didChangeConfiguration', {
    settings = settings,
  })
end

local cmd = {
  'sonarlint-language-server',
  '-stdio',
}

if (vim.uv or vim.loop).fs_stat(extension_dir) then
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
  default_config = {
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
    root_dir = function(fname) return util.find_git_ancestor(fname) end,
    settings = {
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
      ['sonarlint/isOpenInEditor'] = function() return true end,
      ['sonarlint/shouldAnalyzeFile'] = function()
        return {
          shouldBeAnalyzed = true,
        }
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
          vim.api.nvim_buf_set_lines(
            buf,
            -1,
            -1,
            false,
            { '# ' .. language, '' }
          )
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
    },
    commands = {
      LspSonarlintDeactivateRule = function(rule, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        did_change_configuration(client, {
          sonarlint = {
            rules = {
              [rule.arguments[1]] = { level = 'off' },
            },
          },
        })
      end,
    },
  },
  docs = {
    package_json = 'https://raw.githubusercontent.com/SonarSource/sonarlint-vscode/master/package.json',
    description = [[
https://github.com/SonarSource/sonarlint-vscode

SonarLint
]],
  },
}
