local cmp = require('cmp')
local luasnip = require('luasnip')
local compare = require('cmp.config.compare')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp_default_sources = {
  {
    name = 'fuzzy_buffer',
    group_index = 1,
    option = {
      get_bufnrs = function()
        local bufs = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
          if buftype ~= 'nofile' and buftype ~= 'prompt' then
            bufs[#bufs + 1] = buf
          end
        end
        return bufs
      end,
    },
  },
  { name = 'luasnip', group_index = 2 },
  { name = 'nvim_lsp', group_index = 3 },
  { name = 'calc', group_index = 4 },
  { name = 'async_path', group_index = 5 },
  { name = 'tmux', group_index = 6, option = { all_panes = true } },
  { name = 'dap', group_index = 7 },
  { name = 'dynamic', group_index = 8 },
  { name = 'copilot', group_index = 9 },
  { name = 'fuzzy_path', group_index = 10, option = { fd_timeout_msec = 200 } },
}
vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources(cmp_default_sources),
  enabled = function()
    return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt' or require('cmp_dap').is_dap_buffer()
  end,
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping({
      i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
      c = function(fallback)
        if cmp.get_selected_entry() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      end,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  experimental = {
    ghost_text = {
      hl_group = 'CmpGhostText',
    },
  },
  formatting = {
    fields = { 'kind', 'menu', 'abbr' },
    format = function(entry, vim_item)
      if vim.tbl_contains({ 'fuzzy_path', 'async_path', 'path' }, entry.source.name) then
        local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
        if icon then
          vim_item.kind = icon:gsub('^%s+', ''):gsub('%s+$', '') .. ' File'
          vim_item.kind_hl_group = hl_group
        end
      end

      local present, lspkind = pcall(require, 'lspkind')
      local icons = require('core.defaults').icons.kinds

      if not present then
        return vim_item
      else
        local result = lspkind.cmp_format({
          mode = 'symbol_text',
          menu = {
            fuzzy_buffer = '「BUF」',
            luasnip = '「SNIP」',
            nvim_lsp = '「LSP」',
            calc = '「CALC」',
            async_path = '「PATH」',
            fuzzy_path = '「PATH」',
            tmux = '「TMUX」',
            dap = '「DAP」',
            dynamic = '「CUS」',
            browser = '「WWW」',
            copilot = '「COP」',

            fish = '「FISH」',
            ['vim-dadbod-completion'] = '「DB」',
          },
          symbol_map = {
            File = icons.File,
            Module = icons.Module,
            Class = icons.Class,
            Method = icons.Method,
            Property = icons.Property,
            Field = icons.Field,
            Constructor = icons.Constructor,
            Enum = icons.Enum,
            Interface = icons.Interface,
            Function = icons.Function,
            Variable = icons.Variable,
            Constant = icons.Constant,
            Text = icons.Text,
            Keyword = icons.Keyword,
            EnumMember = icons.EnumMember,
            Struct = icons.Struct,
            Event = icons.Event,
            Operator = icons.Operator,
            TypeParameter = icons.TypeParameter,

            Snippet = icons.Snippet,
            Unit = icons.Unit,
            Value = icons.Value,
            Color = icons.Color,
            Reference = icons.Reference,
            Folder = icons.folder,
            Copilot = icons.Copilot,
          },
        })(entry, vim_item)

        local strings = vim.split(result.kind, '%s', { trimempty = true })
        result.kind = ' ' .. (strings[1] or '') .. ' '

        return result
      end
    end,
  },
  window = {
    completion = {
      winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
      col_offset = -3,
      side_padding = 0,
      border = 'rounded',
      scrollbar = '║',
    },
    documentation = {
      border = 'rounded',
    },
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      require('cmp_fuzzy_buffer.compare'),
      require('cmp_fuzzy_path.compare'),
      compare.offset,
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.kind,
      compare.sort_text,
      compare.length,
      compare.order,
    },
  },
})

cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
  sources = {
    { name = 'dap', group_index = 1 },
    { name = 'fuzzy_buffer', group_index = 2 },
  },
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'fuzzy_buffer' },
  },
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'cmdline', group_index = 1 },
    { name = 'fuzzy_path', group_index = 2 },
  },
})

local configs = require('languages').get_cmp_sources()
for _, config in ipairs(configs) do
  local new_sources = vim.deepcopy(cmp_default_sources)
  vim.list_extend(new_sources, config.sources)
  cmp.setup.filetype(config.filetypes, {
    sources = new_sources,
  })
end

local present = pcall(require, 'nvim-autopairs')

if present then
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end
