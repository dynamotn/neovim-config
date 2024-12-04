vim.opt_local.wrap = true
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en_us'

function _G.dynamo_otter_extensions(arglead, _, _)
  require('lazy').load({ plugins = { 'otter' } })
  local extensions = require('otter.tools.extensions')
  local out = {}
  for k, v in pairs(extensions) do
    if arglead == nil then
      table.insert(out, '*.otter.' .. v)
    elseif k:find('^' .. arglead) ~= nil then
      table.insert(out, k)
    end
  end
  return out
end
if not ENABLED_OTTER then
  return
end
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('lspconfig', { clear = false }),
  pattern = 'markdown',
  callback = function(ev)
    local buf = ev.buf
    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
    local matching_configs = require('lspconfig.util').get_config_by_ft(ft)
    for _, config in ipairs(matching_configs) do
      vim.notify('Activating ' .. config.name .. ' LspOtter in buffer ' .. buf .. '...')
      config.launch(buf)
    end
  end,
})
vim.cmd(
  [[ command! -nargs=* -complete=customlist,v:lua.dynamo_otter_extensions LspOtter lua require'otter'.activate({<f-args>}) ]]
)
