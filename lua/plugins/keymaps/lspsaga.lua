return function(whichkey, bufnr)
  whichkey.register({
    ['gd'] = { dynamo_cmdcr('Lspsaga preview_definition'), 'Preview definition' },
    ['gh'] = { dynamo_cmdcr('Lspsaga lsp_finder'), 'Show definition and references' },
    ['K'] = { dynamo_cmdcr('Lspsaga hover_doc'), 'Hover document' },
    ['<leader>k'] = { dynamo_cmdcr('Lspsaga signature_help'), 'Signature help' },
    ['<Space>lr'] = { dynamo_cmdcr('Lspsaga rename'), 'Rename' },
    ['<Space>la'] = { dynamo_cmdcr('Lspsaga code_action'), 'Code Action' },
  }, { buffer = bufnr })

  whichkey.register({
    ['<Space>la'] = { dynamo_cmdcr('<C-u>Lspsaga range_code_action'), 'Code Action' },
  }, { buffer = bufnr, mode = 'v' })
end
