return function(whichkey, bufnr)
  whichkey.register({
    ['gi'] = { dynamo_cmdcr('lua vim.lsp.buf.implementation()'), 'Go to implementation' },
    ['gt'] = { dynamo_cmdcr('lua vim.lsp.buf.type_definition()'), 'Go to type definition' },
    ['gr'] = { dynamo_cmdcr('lua vim.lsp.buf.references()'), 'Go to references' },
    ['<Space>li'] = { dynamo_cmdcr('lua vim.lsp.buf.incoming_calls()'), 'Show incoming calls' },
    ['<Space>lo'] = { dynamo_cmdcr('lua vim.lsp.buf.outgoing_calls()'), 'Show outgoing calls' },
    ['<Space>ff'] = { dynamo_cmdcr('lua vim.lsp.buf.formatting()'), 'File formatting' },
  }, { buffer = bufnr })

  whichkey.register({
    ['<Space>ff'] = { dynamo_cmdcr('lua vim.lsp.buf.range_formatting()'), 'File formatting with range' },
  }, { buffer = bufnr, mode = 'v' })
end
