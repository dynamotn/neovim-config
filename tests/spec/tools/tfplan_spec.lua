local h = require('helpers')

local PLAN = {
  resource_changes = {
    {
      address = 'aws_s3_bucket.logs',
      mode = 'managed',
      type = 'aws_s3_bucket',
      name = 'logs',
      change = { actions = { 'update' } },
    },
    {
      address = 'aws_instance.web[0]',
      mode = 'managed',
      type = 'aws_instance',
      name = 'web',
      change = {
        actions = { 'delete', 'create' },
        replace_paths = { { 'ami' } },
      },
    },
    {
      address = 'aws_instance.web[1]',
      mode = 'managed',
      type = 'aws_instance',
      name = 'web',
      change = {
        actions = { 'create', 'delete' },
        replace_paths = { { 'ami' }, { 'ebs_block_device', 0, 'size' } },
      },
    },
    {
      address = 'data.aws_iam_policy.read',
      mode = 'data',
      type = 'aws_iam_policy',
      name = 'read',
      change = { actions = { 'read' } },
    },
    {
      address = 'module.vpc.aws_subnet.private["a"]',
      module_address = 'module.vpc',
      mode = 'managed',
      type = 'aws_subnet',
      name = 'private',
      change = { actions = { 'create' } },
    },
    {
      address = 'module.vpc.module.nat.aws_eip.this',
      module_address = 'module.vpc.module.nat',
      mode = 'managed',
      type = 'aws_eip',
      name = 'this',
      change = { actions = { 'delete' } },
    },
    {
      address = 'aws_sqs_queue.old',
      mode = 'managed',
      type = 'aws_sqs_queue',
      name = 'old',
      change = { actions = { 'delete' } },
    },
    {
      address = 'aws_kms_key.same',
      mode = 'managed',
      type = 'aws_kms_key',
      name = 'same',
      change = { actions = { 'no-op' } },
    },
  },
}

describe('tools.tfplan', function()
  local tfplan, dir, cleanup

  before_each(function()
    h.unload('tools.tfplan')
    tfplan = require('tools.tfplan')
    dir, cleanup = h.tmpdir()
    h.write(dir .. '/main.tf', {
      'resource "aws_s3_bucket" "logs" {',
      '  bucket = "logs"',
      '}',
      '',
      '  resource "aws_instance" "web" {',
      '  count = 2',
      '}',
      'data "aws_iam_policy" "read" {',
      '}',
    })
    h.write(
      dir .. '/modules.tf',
      { 'module "vpc" {', '  source = "./vpc"', '}' }
    )
    h.write(dir .. '/README.md', { 'resource "aws_x" "not_code" {' })
  end)
  after_each(function()
    tfplan.clear()
    vim.cmd('silent! %bwipeout!')
    cleanup()
  end)

  it('reads the changes of a plan, leaving out what stays', function()
    local changes = tfplan.changes(PLAN)
    assert.equals(7, #changes)
    assert.same({
      action = 'replace',
      address = 'aws_instance.web[1]',
      mode = 'managed',
      type = 'aws_instance',
      name = 'web',
      forces = { 'ami', 'ebs_block_device[0].size' },
    }, changes[3])
    assert.equals('vpc', changes[6].module)
    assert.equals('destroy', changes[6].action)
  end)

  it('finds where each block starts, in the .tf files only', function()
    local blocks = tfplan.index(dir)
    assert.same(
      { file = dir .. '/main.tf', line = 1 },
      blocks['resource.aws_s3_bucket.logs']
    )
    assert.same(
      { file = dir .. '/main.tf', line = 5 },
      blocks['resource.aws_instance.web']
    )
    assert.same(
      { file = dir .. '/main.tf', line = 8 },
      blocks['data.aws_iam_policy.read']
    )
    assert.same({ file = dir .. '/modules.tf', line = 1 }, blocks['module.vpc'])
    assert.is_nil(blocks['resource.aws_x.not_code'])
  end)

  it('says one thing per block, loudest first, with what forces it', function()
    local entries = tfplan.entries(tfplan.changes(PLAN), tfplan.index(dir))
    local by_text = {}
    for _, entry in ipairs(entries) do
      by_text[entry.text] = entry
    end

    local web =
      by_text['-/+ replace ×2 (forced by ami, ebs_block_device[0].size)']
    assert.equals(5, web.line)
    assert.equals(vim.diagnostic.severity.WARN, web.severity)

    assert.equals(1, by_text['~ update in place'].line)
    assert.equals(
      vim.diagnostic.severity.INFO,
      by_text['~ update in place'].severity
    )
    assert.equals(8, by_text['<= read'].line)

    -- A module gathers every change below it, nested modules included
    local vpc = by_text['- destroy, + create']
    assert.equals(dir .. '/modules.tf', vpc.file)
    assert.equals(vim.diagnostic.severity.WARN, vpc.severity)

    -- A block that is nowhere in the files still says what it is
    local old = by_text['aws_sqs_queue.old: - destroy']
    assert.is_nil(old.file)
  end)

  it('sums the plan up the way plan does', function()
    assert.equals(
      'Plan: 1 to add, 1 to change, 2 to destroy, 2 to replace',
      tfplan.summary(tfplan.changes(PLAN))
    )
    assert.equals('No changes', tfplan.summary({}))
  end)

  describe('plan', function()
    local path, bin, restore_notify, notes

    before_each(function()
      bin = dir .. '/bin'
      vim.fn.mkdir(bin, 'p')
      h.write(dir .. '/plan.json', { vim.json.encode(PLAN) })
      -- A tofu that plans into the file it is given and shows plan.json
      h.write(bin .. '/tofu', {
        '#!/bin/sh',
        'case "$1" in',
        '  plan) for a; do case "$a" in -out=*) echo plan > "${a#-out=}";; esac; done',
        '        echo "$@" > "' .. dir .. '/plan.args";;',
        '  show) test -f "$3" || exit 3; cat "' .. dir .. '/plan.json";;',
        'esac',
      })
      vim.fn.setfperm(bin .. '/tofu', 'rwxr-xr-x')
      path = vim.env.PATH
      vim.env.PATH = bin .. ':' .. path
      notes = {}
      restore_notify = h.stub(
        vim,
        'notify',
        function(msg) table.insert(notes, msg) end
      )
    end)
    after_each(function()
      vim.env.PATH = path
      restore_notify()
    end)

    it('plans the module of the buffer and shows it on its blocks', function()
      vim.cmd.edit(dir .. '/main.tf')
      local bufnr = vim.api.nvim_get_current_buf()
      tfplan.plan()
      assert.is_true(
        vim.wait(10000, function() return #notes >= 2 end, 20),
        'the plan never finished'
      )
      assert.equals(
        'Plan: 1 to add, 1 to change, 2 to destroy, 2 to replace',
        notes[#notes]
      )

      local args = table.concat(vim.fn.readfile(dir .. '/plan.args'), ' ')
      assert.is_truthy(args:find('-lock=false', 1, true))
      assert.is_truthy(args:find('-input=false', 1, true))
      -- The plan file, secrets and all, is gone once it was read
      local planfile = args:match('%-out=(%S+)')
      assert.equals(0, vim.fn.filereadable(planfile))

      local messages = vim.tbl_map(
        function(d) return d.lnum .. ' ' .. d.message end,
        vim.diagnostic.get(bufnr)
      )
      table.sort(messages)
      assert.same({
        '0 ~ update in place',
        '4 -/+ replace ×2 (forced by ami, ebs_block_device[0].size)',
        '7 <= read',
      }, messages)
      assert.equals(5, #vim.fn.getqflist())

      tfplan.clear()
      assert.same({}, vim.diagnostic.get(bufnr))
      assert.same({}, vim.fn.getqflist())
    end)

    it('says why a plan failed', function()
      h.write(
        bin .. '/tofu',
        { '#!/bin/sh', 'echo "Error: no credentials" >&2', 'exit 1' }
      )
      vim.cmd.edit(dir .. '/main.tf')
      tfplan.plan()
      assert.is_true(vim.wait(10000, function() return #notes >= 2 end, 20))
      assert.is_truthy(
        notes[#notes]:find('plan failed:\nError: no credentials', 1, true)
      )
    end)
  end)

  it(
    'counts what a removed block forgets',
    function()
      assert.equals(
        'Plan: 0 to add, 0 to change, 0 to destroy, 0 to replace, 1 to forget',
        tfplan.summary({ { action = 'forget' } })
      )
    end
  )
end)
