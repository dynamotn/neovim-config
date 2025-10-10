return {
  {
    'mason-org/mason.nvim',
    opts = {
      -- Disable default tools
      ensure_installed = {},
      -- Add custom registries
      registries = {
        -- 'file:' .. vim.fn.stdpath('config') .. '/mason-registry',
        -- HACK: I can't use file method because it's lazy load and slow to
        -- append to mason registry and affect to initialize
        -- my custom LSP servers
        'lua:tools.mason-registry',
        'github:mason-org/mason-registry',
      },
    },
  },
}
