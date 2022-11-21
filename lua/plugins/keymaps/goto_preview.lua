return {
  ['gpd'] = { dynamo_cmdcr('lua require("goto-preview").goto_preview_definition()'), 'Preview definition' },
  ['gpt'] = { dynamo_cmdcr('lua require("goto-preview").goto_preview_type_definition()'), 'Preview type definition' },
  ['gpi'] = { dynamo_cmdcr('lua require("goto-preview").goto_preview_implementation()'), 'Preview implementation' },
  ['gpr'] = { dynamo_cmdcr('lua require("goto-preview").goto_preview_references()'), 'Preview references' },
}
