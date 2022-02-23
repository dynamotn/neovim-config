local present, neogit = pcall(require, 'neogit')

if not present then
    return
end

neogit.setup({
    integrations = {
        diffview = true
    }
})
