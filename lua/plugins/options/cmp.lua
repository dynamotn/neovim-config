local present, cmp = pcall(require, 'cmp')

if not present then
  return
end

local present, luasnip = pcall(require, 'luasnip')
if not present then
  return
end

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp_default_sources = {
  { name = 'nvim_lsp' },
  { name = 'luasnip' },
  { name = 'buffer' },
  { name = 'buffer-lines' },
  { name = 'calc' },
  { name = 'path' },
  { name = 'tmux', option = { all_panes = true } },
  { name = 'cmp_tabnine' },
  { name = 'treesitter' },
  { name = 'dynamic' },
}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources(cmp_default_sources, { { name = 'buffer' } }),
  enabled = function()
    return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt' or require('cmp_dap').is_dap_buffer()
  end,
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  formatting = {
    format = function(entry, vim_item)
      if vim.tbl_contains({ 'path' }, entry.source.name) then
        local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
        if icon then
          vim_item.kind = icon:gsub('^%s+', ''):gsub('%s+$', '') .. ' File'
          vim_item.kind_hl_group = hl_group
        end
      end

      local present, lspkind = pcall(require, 'lspkind')

      if not present then
        return vim_item
      else
        return lspkind.cmp_format({
          mode = 'symbol_text',
          menu = {
            nvim_lsp = '「LSP」',
            luasnip = '「SNIP」',
            buffer = '「BUF」',
            ['buffer-lines'] = '「LINE」',
            calc = '「CALC」',
            path = '「PATH」',
            tmux = '「TMUX」',
            cmp_tabnine = '「T9」',
            dap = '「DAP」',
            treesitter = '「TS」',
            dynamic = '「ULT」',

            nvim_lua = '「NLUA」',
            neorg = '「ORG」',
            fish = '「FISH」',
          },
          symbol_map = {
            File = ' ',
            Module = ' ',
            Class = ' ',
            Method = ' ',
            Property = ' ',
            Field = ' ',
            Constructor = ' ',
            Enum = '練',
            Interface = ' ',
            Function = ' ',
            Variable = '',
            Constant = ' ',
            Text = ' ', -- String in barbecue
            Keyword = ' ', -- Key in barbecue
            EnumMember = ' ',
            Struct = ' ',
            Event = ' ',
            Operator = ' ',
            TypeParameter = ' ',

            Snippet = ' ',
            Unit = ' ',
            Value = ' ',
            Color = ' ',
            Reference = ' ',
            Folder = ' ',
          },
        })(entry, vim_item)
      end
    end,
  },
})

cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
  sources = {
    { name = 'dap' },
  },
})

local configs = require('languages').get_cmp_sources()
for _, config in ipairs(configs) do
  cmp.setup.filetype(config.filetypes, {
    sources = vim.tbl_extend('force', cmp_default_sources, config.sources),
  })
end
