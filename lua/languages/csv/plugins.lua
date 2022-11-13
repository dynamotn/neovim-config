return function(register_config, filetypes)
  return {
    { 'mechatroner/rainbow_csv', config = register_config('rainbow_csv', filetypes) }, -- Highlight column csv
    { 'dynamotn/csv.vim' }, -- Navigation in file
  }
end
