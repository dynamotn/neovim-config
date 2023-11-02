vim.g.do_filetype_lua = 1

vim.filetype.add({
  extension = {
    envrc = 'sh',
    ino = 'arduino',
    pde = 'arduino',
    gotmpl = 'gotmpl',
  },
  filename = {
    ['.git/ignore'] = 'gitignore',
    ['terragrunt.hcl'] = 'terragrunt',
  },
  pattern = {
    ['.*%.hcl'] = 'terragrunt',
    ['.*terraform/.*%.hcl'] = 'terragrunt',
    ['ansible/.*%.ya?ml'] = 'ansible',
    ['tasks/.*%.ya?ml'] = 'ansible',
    ['roles/.*%.ya?ml'] = 'ansible',
    ['handlers/.*%.ya?ml'] = 'ansible',
    ['inventory/.*%.ya?ml'] = 'ansible',
    ['.*%.tmpl'] = 'gotmpl',
    ['.*%.dbml'] = 'dbml',
    ['.*%.d2'] = 'd2',
    ['.*%.tpl'] = {
      priority = -math.huge,
      function(_, bufnr)
        return require('util.filetype').detect_gotemplate(bufnr)
      end,
    },
    ['.*%.ya?ml'] = {
      priority = -math.huge,
      function(_, bufnr)
        return require('util.filetype').detect_gotemplate(bufnr)
      end,
    },
  },
})
