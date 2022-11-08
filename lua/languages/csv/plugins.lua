return function(register_config)
  return {
    { 'mechatroner/rainbow_csv', config = register_config('rainbow_csv') },
    { 'dynamotn/csv.vim' },
  }
end
