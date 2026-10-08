local h = require('helpers')

describe('util.lsp', function()
  local lsp, calls, enabled, restore

  --- Stand in for `vim.lsp.codelens`, with `enable` only when `native`
  ---@param native boolean
  local function codelens(native)
    local fake = {
      refresh = function(opts) table.insert(calls, { 'refresh', opts }) end,
    }
    if native then
      fake.enable = function(on, filter)
        enabled[filter.bufnr] = on
        table.insert(calls, { 'enable', on, filter })
      end
      fake.is_enabled = function(filter) return enabled[filter.bufnr] == true end
    end
    restore = h.stub(vim.lsp, 'codelens', fake)
  end

  before_each(function()
    calls, enabled = {}, {}
    h.unload('util.lsp')
    lsp = require('util.lsp')
  end)
  after_each(function() restore() end)

  describe('codelens', function()
    it('enables the lenses of the buffer where Neovim can', function()
      codelens(true)
      lsp.codelens.enable(7)
      assert.same({ { 'enable', true, { bufnr = 7 } } }, calls)
    end)

    it('refreshes that buffer alone on the events otherwise', function()
      codelens(false)
      local buf = vim.api.nvim_create_buf(true, false)
      lsp.codelens.enable(buf)
      vim.api.nvim_exec_autocmds('InsertLeave', { buffer = buf })
      assert.same({
        { 'refresh', { bufnr = buf } },
        { 'refresh', { bufnr = buf } },
      }, calls)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it('toggles the lenses of the current buffer', function()
      codelens(true)
      local buf = vim.api.nvim_get_current_buf()
      lsp.codelens.toggle()
      assert.is_true(enabled[buf])
      lsp.codelens.toggle()
      assert.is_false(enabled[buf])
    end)
  end)
end)
