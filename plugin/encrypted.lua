-- SOPS files, Ansible Vaults and the encrypted files of a chezmoi source
-- open decrypted and are written back encrypted (`tools.encrypted`). Only a
-- buffer that holds one loads the module: the check here is a plain search.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('dy_encrypted', { clear = true }),
  callback = function(args)
    local name = vim.fs.basename(vim.api.nvim_buf_get_name(args.buf))
    local first = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] or ''
    if
      not name:match('^encrypted_.+%.age$')
      and not name:match('^encrypted_.+%.asc$')
      and not first:find('$ANSIBLE_VAULT;', 1, true)
      -- In the buffer read, which need not be the current one
      and vim.api.nvim_buf_call(
          args.buf,
          function() return vim.fn.search('ENC\\[AES256_GCM,', 'nw') end
        )
        == 0
    then
      return
    end
    require('tools.encrypted').open(args.buf)
  end,
})

-- `:EncryptedDiff [{rev}]`: the clear text of this decrypted buffer against
-- its clear text at {rev}, `HEAD` unless given
vim.api.nvim_create_user_command(
  'EncryptedDiff',
  function(args) require('tools.encrypted').command(args) end,
  {
    nargs = '?',
    desc = 'Diff this decrypted file with its clear text at a revision',
  }
)

-- `:EncryptedKeys`, `:EncryptedRotate [updatekeys|rotate]`: the recipients
-- of this sops file, and putting new ones or a new data key in place
vim.api.nvim_create_user_command(
  'EncryptedKeys',
  function() require('tools.encrypted').keys() end,
  { desc = 'The recipients of this sops file' }
)
vim.api.nvim_create_user_command(
  'EncryptedRotate',
  function(args) require('tools.encrypted').rotate(args.fargs[1]) end,
  {
    nargs = '?',
    complete = function() return { 'updatekeys', 'rotate' } end,
    desc = 'Apply .sops.yaml to this sops file, or give it a new data key',
  }
)
