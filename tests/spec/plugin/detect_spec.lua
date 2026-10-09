local h = require('helpers')

-- The startup shims that look into a buffer before loading their tool, and
-- leave alone what the tool would not read anyway
describe('plugin detection', function()
  local seen, restores
  before_each(function()
    seen = {}
    restores = {
      h.stub(package.loaded, 'tools.cron', {
        attach = function(bufnr) table.insert(seen, { 'cron', bufnr }) end,
      }),
      h.stub(package.loaded, 'tools.encrypted', {
        open = function(bufnr) table.insert(seen, { 'encrypted', bufnr }) end,
      }),
    }
    dofile(h.root .. '/plugin/cron.lua')
    dofile(h.root .. '/plugin/encrypted.lua')
  end)
  after_each(function()
    for i = #restores, 1, -1 do
      restores[i]()
    end
    vim.cmd('silent! %bwipeout!')
  end)

  --- `count` filler lines, then `lines`
  ---@param count integer
  ---@param lines string[]
  ---@return string[]
  local function after(count, lines)
    local out = {}
    for index = 1, count do
      out[index] = 'key' .. index .. ': value'
    end
    return vim.list_extend(out, lines)
  end

  describe('cron', function()
    it('attaches to a YAML buffer with a schedule', function()
      local bufnr = h.buffer({ lines = { 'on:', '  - cron: "0 * * * *"' } })
      vim.bo[bufnr].filetype = 'yaml'
      assert.are.same({ { 'cron', bufnr } }, seen)
    end)

    it('leaves a YAML buffer without one alone', function()
      local bufnr = h.buffer({ lines = { 'name: web', 'crontab: no' } })
      vim.bo[bufnr].filetype = 'yaml'
      assert.are.same({}, seen)
    end)

    it('reads no further than the module does', function()
      local bufnr = h.buffer({ lines = after(5000, { 'schedule: "@daily"' }) })
      vim.bo[bufnr].filetype = 'yaml'
      assert.are.same({}, seen)
    end)
  end)

  describe('encrypted', function()
    --- Fire the shim's `BufReadPost` on a buffer holding `lines`
    ---@param lines string[]
    ---@return integer bufnr
    local function read(lines)
      local bufnr = h.buffer({ name = vim.fn.tempname(), lines = lines })
      vim.api.nvim_exec_autocmds('BufReadPost', { buffer = bufnr })
      return bufnr
    end

    it('opens a buffer holding a sops value', function()
      local bufnr = read({ 'a: 1', 'b: ENC[AES256_GCM,data:x,type:str]' })
      assert.are.same({ { 'encrypted', bufnr } }, seen)
    end)

    it('opens an Ansible Vault by its header', function()
      local bufnr = read({ '$ANSIBLE_VAULT;1.1;AES256', '6162' })
      assert.are.same({ { 'encrypted', bufnr } }, seen)
    end)

    it('leaves an ordinary buffer alone', function()
      read({ 'a: 1', 'ENC[AES256 is how sops writes a value' })
      assert.are.same({}, seen)
    end)

    it('leaves a buffer longer than the module opens', function()
      read(after(20000, { 'b: ENC[AES256_GCM,data:x,type:str]' }))
      assert.are.same({}, seen)
    end)
  end)
end)
