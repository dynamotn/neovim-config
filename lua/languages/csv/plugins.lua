return function(register_config)
  return {
    { 'mechatroner/rainbow_csv', config = register_config('rainbow_csv') }, -- Highlight column csv
    { 'dynamotn/csv.vim' }, -- Navigation in file
  }
end
