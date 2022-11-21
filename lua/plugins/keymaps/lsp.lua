return function(whichkey, bufnr)
  whichkey.register({
    ['gd'] = { dynamo_cmdcr('lua vim.lsp.buf.definition()'), 'Go to definition' },
    ['gi'] = { dynamo_cmdcr('lua vim.lsp.buf.implementation()'), 'Go to implementation' },
    ['gt'] = { dynamo_cmdcr('lua vim.lsp.buf.type_definition()'), 'Go to type definition' },
    ['gr'] = { dynamo_cmdcr('lua vim.lsp.buf.references()'), 'Go to references' },
    ['K'] = { dynamo_cmdcr('lua vim.lsp.buf.hover()'), 'Hover document' },
    ['<leader>k'] = { dynamo_cmdcr('lua vim.lsp.buf.signature_help()'), 'Signature help' },
    ['<Space>la'] = { dynamo_cmdcr('lua vim.lsp.buf.code_action()'), 'Code Action' },
    ['<Space>li'] = { dynamo_cmdcr('lua vim.lsp.buf.incoming_calls()'), 'Show incoming calls' },
    ['<Space>lo'] = { dynamo_cmdcr('lua vim.lsp.buf.outgoing_calls()'), 'Show outgoing calls' },
    ['<Space>lr'] = { dynamo_cmdcr('lua vim.lsp.buf.rename()'), 'Rename' },
    ['<Space>ff'] = { dynamo_cmdcr('lua vim.lsp.buf.formatting()'), 'File formatting' },
  }, { buffer = bufnr })

  whichkey.register({
    ['<Space>la'] = { dynamo_cmdcr('lua vim.lsp.buf.range_code_action()'), 'Code Action' },
    ['<Space>ff'] = { dynamo_cmdcr('lua vim.lsp.buf.range_formatting()'), 'File formatting with range' },
  }, { buffer = bufnr, mode = 'v' })
end
