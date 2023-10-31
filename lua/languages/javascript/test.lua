return require('neotest-jest')({
  jestCommand = 'npm test --',
  jestConfigFile = 'custom.jest.config.ts',
  env = { CI = true },
  cwd = function(_)
    return require('util.root').get()
  end,
})
