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
      ['ansible/.*.yml'] = 'ansible',
    },
  },
})

vim.cmd([[
runtime! ftdetect/*.vim
runtime! ftdetect/*.lua
]])
vim.g.did_load_ftdetect = 1
