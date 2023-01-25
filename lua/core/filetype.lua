vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

vim.filetype.add({
  extension = {
    envrc = 'sh',
    ino = 'arduino',
    pde = 'arduino',
  },
  filename = {
    ['.git/ignore'] = 'gitignore',
    ['terragrunt.hcl'] = 'terragrunt',
  },
  pattern = {
    ['.*terraform/.*%.hcl$'] = 'terragrunt',
    ['ansible/.*%.ya?ml$'] = 'ansible',
    ['tasks/.*%.ya?ml$'] = 'ansible',
    ['roles/.*%.ya?ml$'] = 'ansible',
    ['handlers/.*%.ya?ml$'] = 'ansible',
    ['inventory/.*%.ya?ml$'] = 'ansible',
  },
})
