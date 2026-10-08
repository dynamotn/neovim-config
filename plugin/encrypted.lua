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
      and vim.fn.search('ENC\\[AES256_GCM,', 'nw') == 0
    then
      return
    end
    require('tools.encrypted').open(args.buf)
  end,
})
