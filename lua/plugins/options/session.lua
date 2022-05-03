local present, session = pcall(require, 'persisted')

if not present then
    return
end

session.setup({
    autosave = true,
    autoload = true,
    use_git_branch = true,
    telescope = {
        before_source = function()
            -- Close all open buffers
            pcall(vim.cmd, "bufdo bwipeout")
        end,
        after_source = function(_)
            -- Change the git branch
            pcall(vim.cmd, "git checkout " .. session.branch)
        end,
    },
})

local present, telescope = pcall(require, 'telescope')

if not present then
    return
end

telescope.load_extension("persisted")
