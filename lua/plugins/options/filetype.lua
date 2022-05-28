local present, filetype = pcall(require, 'filetype')

if not present then
  return
end

filetype.setup({
  overrides = {
    extensions = {
      envrc = 'sh',
    },
    complex = {
      ['.git/ignore'] = 'gitignore',
      ['terragrunt.hcl'] = 'terragrunt',
      ['terraform/*.hcl'] = 'terragrunt',
      ['ansible/.*.ya?ml'] = 'ansible',
      ['tasks/.*.ya?ml'] = 'ansible',
      ['roles/.*.ya?ml'] = 'ansible',
      ['handlers/.*.ya?ml'] = 'ansible',
      ['inventory/.*.ya?ml'] = 'ansible',
    },
  },
})

vim.cmd([[
runtime! ftdetect/*.vim
runtime! ftdetect/*.lua
]])
vim.g.did_load_ftdetect = 1
