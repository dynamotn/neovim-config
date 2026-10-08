return {
  {
    -- For gentoo filetypes
    'gentoo/gentoo-syntax',
    enabled = _G.used_full_plugins or _G.is_gentoo,
  },
  {
    -- Comment strings by treesitter language, for files mixing several of
    -- them, and uncommenting that takes any of a language's styles
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
}
