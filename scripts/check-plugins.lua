-- Fail when a plugin of this configuration is not installed, and name it.
--
-- `:Lazy! restore` exits 0 even when a clone failed, so a host being down
-- -- Codeberg answering 503 -- only shows up later, as the configuration
-- failing to load for a reason that no longer mentions the plugin. Run after
-- the configuration is loaded:
--
--   nvim --headless -c 'luafile scripts/check-plugins.lua'

local missing = {} ---@type string[]
for name, plugin in pairs(require('lazy.core.config').plugins) do
  if not plugin._.installed then table.insert(missing, name) end
end
table.sort(missing)

if #missing > 0 then
  io.stderr:write(
    'check-plugins: not installed: ' .. table.concat(missing, ', ') .. '\n'
  )
  vim.cmd('cquit')
end
vim.cmd('qall!')
