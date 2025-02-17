return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- I don't want to use default LazyVim parsers
    opts = function(_, opts)
      opts.ensure_installed = {
        'diff', -- for diff file
        'comment', -- for comment tags
        'query', -- for treesitter itself query
        'regex', -- for regex
        'vim', -- for old vim script
        'vimdoc', -- for vim help files
        'markdown', -- for document via LSP and treesitter
        'markdown_inline', -- for document via LSP and treesitter
      }
    end,
  },
}
