return function(register_config, filetypes)
  return {
    { 'mechatroner/rainbow_csv', name = 'rainbow_csv', config = register_config }, -- Highlight column csv
    { 'dynamotn/csv.vim' }, -- Navigation in file
  }
end
