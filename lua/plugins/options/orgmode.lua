return function(filetypes)
  local present, orgmode = pcall(require, 'orgmode')

  if not present then
    return
  end

  orgmode.setup({
    org_agenda_files = { '~/Note/*' },
    org_default_notes_file = '~/Note/dynamo.org',
  })
end
