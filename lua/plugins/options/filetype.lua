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
        },
    },
})
