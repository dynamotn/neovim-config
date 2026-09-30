--- Lua patterns, matched against the lower-cased key, of values worth hiding
--- in any file camouflage parses
local secret_keys = {
  'password',
  'passwd',
  'passphrase',
  'secret',
  'token',
  'credential',
  'api[_%-]*key',
  'access[_%-]*key',
  'private[_%-]*key',
}

return {
  {
    -- Mask secret values on screen, without touching the file
    'zeybek/camouflage.nvim',
    -- Not `BufReadPre`, as its README has it: loaded then, it builds a
    -- treesitter parser for a buffer the file is not read into yet, and that
    -- buffer keeps an empty tree -- no highlighting, and nothing to mask.
    event = 'LazyFile',
    cmd = { 'CamouflageToggle', 'CamouflageReveal', 'CamouflageYank' },
    keys = {
      { '<leader>uk', '<cmd>CamouflageToggle<cr>', desc = 'Toggle Camouflage' },
      {
        '<leader>uK',
        '<cmd>CamouflageFollowCursor<cr>',
        desc = 'Toggle Camouflage Reveal Under Cursor',
      },
    },
    opts = {
      hooks = {
        -- Out of the box every value of every YAML, JSON or shell file is
        -- masked, which leaves a Kubernetes manifest unreadable. A file
        -- `util.sensitive` flags keeps all of its values hidden; everywhere
        -- else only the ones whose key names a secret are.
        on_variable_detected = function(bufnr, var)
          if require('util.sensitive').is_sensitive(bufnr) then return true end
          local key = (var.key or ''):lower()
          for _, pattern in ipairs(secret_keys) do
            if key:find(pattern) then return true end
          end
          return false
        end,
      },
      integrations = {
        -- It turns completion off through `require('cmp')`, which here is
        -- blink.compat's shim, and for the whole buffer at that: any YAML
        -- with a `password:` in it would lose its schema completion.
        cmp = { disable_in_masked = false },
        blink = { disable_in_masked = false },
      },
      project_config = {
        -- A `.camouflage.yaml` in a cloned repository can turn masking off
        -- for its files, so it is only read once `:trust`ed.
        secure = true,
      },
    },
  },
}
