-- SOPS files, Ansible Vaults and the encrypted files of a chezmoi source
-- open decrypted and are written back encrypted (`tools.encrypted`). Only a
-- buffer that holds one loads the module: the check here is a plain search.

-- The most lines `tools.encrypted` opens; a longer buffer is not read here
local MAX_LINES = 20000

--- Whether `bufnr` holds a sops value, by plain search of its lines
---@param bufnr integer
---@return boolean
local function has_sops_value(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:find('ENC[AES256_GCM,', 1, true) then return true end
  end
  return false
end

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('dy_encrypted', { clear = true }),
  callback = function(args)
    if vim.api.nvim_buf_line_count(args.buf) > MAX_LINES then return end
    local name = vim.fs.basename(vim.api.nvim_buf_get_name(args.buf))
    local first = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] or ''
    if
      not name:match('^encrypted_.+%.age$')
      and not name:match('^encrypted_.+%.asc$')
      and not first:find('$ANSIBLE_VAULT;', 1, true)
      and not has_sops_value(args.buf)
    then
      return
    end
    require('tools.encrypted').open(args.buf)
  end,
})

-- `:DyEncryptedDiff [{rev}]`: the clear text of this decrypted buffer against
-- its clear text at {rev}, `HEAD` unless given
vim.api.nvim_create_user_command(
  'DyEncryptedDiff',
  function(args) require('tools.encrypted').command(args) end,
  {
    nargs = '?',
    desc = 'Diff this decrypted file with its clear text at a revision',
  }
)

-- `:DyEncryptedKeys`, `:DyEncryptedRotate [updatekeys|rotate]`: the recipients
-- of this sops file, and putting new ones or a new data key in place
vim.api.nvim_create_user_command(
  'DyEncryptedKeys',
  function() require('tools.encrypted').keys() end,
  { desc = 'The recipients of this sops file' }
)
vim.api.nvim_create_user_command(
  'DyEncryptedRotate',
  function(args) require('tools.encrypted').rotate(args.fargs[1]) end,
  {
    nargs = '?',
    complete = function() return { 'updatekeys', 'rotate' } end,
    desc = 'Apply .sops.yaml to this sops file, or give it a new data key',
  }
)
