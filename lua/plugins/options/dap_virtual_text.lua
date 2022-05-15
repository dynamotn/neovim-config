local present, dap_virtual_text = pcall(require, 'nvim-dap-virtual-text')

if not present then
    return
end

dap_virtual_text.setup({})
