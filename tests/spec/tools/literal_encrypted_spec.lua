local h = require('helpers')

describe('tools.encrypted', function()
  local encrypted, dir, cleanup, path, notes, restore_notify, log

  --- An executable `name` in the scratch bin directory
  local function tool(name, lines)
    local file = dir .. '/bin/' .. name
    h.write(
      file,
      vim.list_extend(
        { '#!/bin/sh', 'echo "' .. name .. ' $*" >> "' .. log .. '"' },
        lines
      )
    )
    vim.fn.setfperm(file, 'rwxr-xr-x')
  end

  before_each(function()
    h.unload('tools.encrypted')
    encrypted = require('tools.encrypted')
    dir, cleanup = h.tmpdir()
    log = dir .. '/calls.log'
    vim.fn.mkdir(dir .. '/bin', 'p')
    path = vim.env.PATH
    vim.env.PATH = dir .. '/bin:' .. path
    notes = {}
    restore_notify = h.stub(
      vim,
      'notify',
      function(msg) table.insert(notes, msg) end
    )

    -- Each fake keeps the clear text behind a prefix: `plain: ` for sops,
    -- `enc:` under a vault header, `age:` for chezmoi
    tool('sops', {
      'case "$1" in',
      '  decrypt) sed -n "s/^plain: //p" "$2";;',
      '  edit) t=$(mktemp); sed -n "s/^plain: //p" "$2" > "$t"; cp "$t" "$t.orig"',
      '        $SOPS_EDITOR "$t"',
      '        if cmp -s "$t" "$t.orig"; then exit 200; fi',
      '        { sed "s/^/plain: /" "$t"; echo "x: ENC[AES256_GCM,data:x]"; echo "sops:"; } > "$2";;',
      'esac',
    })
    tool('ansible-vault', {
      'case "$1" in',
      '  decrypt) sed 1d "$4" | sed "s/^enc://";;',
      '  encrypt) { echo "\\$ANSIBLE_VAULT;1.1;AES256"; sed "s/^/enc:/" "$4"; } > "$3";;',
      'esac',
    })
    tool('chezmoi', {
      'case "$1" in',
      '  decrypt) sed "s/^age://" "$2";;',
      '  encrypt) sed "s/^/age:/" "$4" > "$3";;',
      'esac',
    })
  end)
  after_each(function()
    vim.env.PATH = path
    restore_notify()
    vim.cmd('silent! %bwipeout!')
    cleanup()
  end)

  local function calls() return vim.fn.readfile(log) end

  --- Open `file` the way the BufReadPost hook does
  local function open(file)
    vim.cmd.edit(file)
    local bufnr = vim.api.nvim_get_current_buf()
    return bufnr, encrypted.open(bufnr)
  end

  describe('kind', function()
    it('tells sops by its values and its metadata', function()
      assert.equals(
        'sops',
        encrypted.kind({ 'a: ENC[AES256_GCM,data:x]', 'sops:', '  mac: x' })
      )
      assert.equals(
        'sops',
        encrypted.kind({
          '{',
          '  "a": "ENC[AES256_GCM,data:x]",',
          '  "sops": {',
        })
      )
      assert.equals(
        'sops',
        encrypted.kind({ 'A=ENC[AES256_GCM,data:x]', 'sops_version=3.9.0' })
      )
      assert.is_nil(
        encrypted.kind({ 'note: ENC[AES256_GCM, is how sops writes it' })
      )
    end)

    it('tells Ansible Vault by its header, chezmoi by its file name', function()
      assert.equals(
        'ansible',
        encrypted.kind({ '$ANSIBLE_VAULT;1.1;AES256', '6162' })
      )
      assert.equals(
        'chezmoi',
        encrypted.kind({ 'anything' }, '/s/encrypted_private_dot_netrc.age')
      )
      assert.equals('chezmoi', encrypted.kind({}, '/s/encrypted_dot_key.asc'))
      assert.is_nil(encrypted.kind({ 'x' }, '/s/private_dot_netrc.age'))
      assert.equals(
        'prod',
        encrypted.vault_id('$ANSIBLE_VAULT;1.2;AES256;prod')
      )
      assert.is_nil(encrypted.vault_id('$ANSIBLE_VAULT;1.1;AES256'))
    end)
  end)

  it('opens sops in the clear, and writes it back through sops edit', function()
    local file = dir .. '/values.yaml'
    h.write(
      file,
      { 'plain: password: hunter2', 'x: ENC[AES256_GCM,data:x]', 'sops:' }
    )
    local bufnr, decrypted = open(file)

    assert.is_true(decrypted)
    assert.same(
      { 'password: hunter2' },
      vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    )
    assert.is_true(require('util.sensitive').is_sensitive(bufnr))
    assert.is_false(vim.bo[bufnr].swapfile)
    assert.is_false(vim.bo[bufnr].undofile)
    assert.is_false(vim.bo[bufnr].modified)

    -- No undoing back to the ciphertext
    vim.cmd('silent! undo')
    assert.same(
      { 'password: hunter2' },
      vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    )

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'password: changed' })
    vim.cmd('write')
    assert.is_false(vim.bo[bufnr].modified)
    assert.same(
      { 'plain: password: changed', 'x: ENC[AES256_GCM,data:x]', 'sops:' },
      vim.fn.readfile(file)
    )
    assert.equals('sops edit ' .. file, calls()[2])
    assert.equals('Written, encrypted with sops', notes[#notes])
  end)

  it('takes sops leaving an unchanged file alone as written', function()
    local file = dir .. '/values.yaml'
    h.write(file, { 'plain: a: 1', 'x: ENC[AES256_GCM,data:x]', 'sops:' })
    local bufnr = open(file)
    assert.is_true(encrypted.write(bufnr))
    assert.same(
      { 'plain: a: 1', 'x: ENC[AES256_GCM,data:x]', 'sops:' },
      vim.fn.readfile(file)
    )
  end)

  it('gives up at once when sops rejects what it got back', function()
    -- sops asks the editor again when it cannot parse the result
    tool('sops', {
      'case "$1" in',
      '  decrypt) sed -n "s/^plain: //p" "$2";;',
      '  edit) t=$(mktemp); $SOPS_EDITOR "$t" || exit 9',
      '        $SOPS_EDITOR "$t" || { rm -f "$t"; exit 128; }',
      '        exit 0;;',
      'esac',
    })
    local file = dir .. '/values.yaml'
    h.write(file, { 'plain: a: 1', 'x: ENC[AES256_GCM,data:x]', 'sops:' })
    local bufnr = open(file)
    local started = vim.uv.hrtime()
    assert.is_false(encrypted.write(bufnr))
    assert.is_true((vim.uv.hrtime() - started) / 1e6 < 5000)
    assert.is_truthy(notes[#notes]:find('Not written', 1, true))
    -- Nothing of the copy and its editor left in the temporary directory
    local leftovers =
      vim.fn.glob(vim.fs.dirname(vim.fn.tempname()) .. '/*', false, true)
    for _, left in ipairs(leftovers) do
      assert.is_nil(left:find('%.editor$'), left)
      assert.is_nil(left:find('%.used$'), left)
    end
  end)

  it('encrypts once per write, however often the file was opened', function()
    local file = dir .. '/values.yaml'
    h.write(file, { 'plain: a: 1', 'x: ENC[AES256_GCM,data:x]', 'sops:' })
    local bufnr = open(file)
    vim.cmd('bdelete')
    vim.cmd.edit(file)
    encrypted.open(bufnr)
    vim.fn.writefile({}, log)
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { 'a: 2' })
    vim.cmd('write')
    local edits = vim.tbl_filter(
      function(line) return line:find('^sops edit') ~= nil end,
      calls()
    )
    assert.equals(1, #edits)
  end)

  it('keeps the clear text out of the system clipboard', function()
    local saved = vim.o.clipboard
    vim.o.clipboard = 'unnamedplus'
    local file = dir .. '/values.yaml'
    h.write(file, { 'plain: a: 1', 'x: ENC[AES256_GCM,data:x]', 'sops:' })
    open(file)
    assert.equals('', vim.o.clipboard)
    vim.cmd.enew()
    assert.equals('unnamedplus', vim.o.clipboard)
    vim.o.clipboard = saved
  end)

  it('gives the clipboard back after the buffer was guarded again', function()
    local saved = vim.o.clipboard
    vim.o.clipboard = 'unnamedplus'
    local file = dir .. '/values.yaml'
    h.write(file, { 'plain: a: 1', 'x: ENC[AES256_GCM,data:x]', 'sops:' })
    local bufnr = open(file)
    -- What `:e!` does, with the clipboard already cleared
    encrypted.guard(bufnr)
    vim.cmd.enew()
    assert.equals('unnamedplus', vim.o.clipboard)
    vim.o.clipboard = saved
  end)

  it('keeps the vault id of an Ansible Vault', function()
    local file = dir .. '/vault.yml'
    h.write(file, { '$ANSIBLE_VAULT;1.2;AES256;prod', 'enc:db_password: x' })
    local bufnr = open(file)
    assert.same(
      { 'db_password: x' },
      vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    )
    vim.cmd('write')
    local encrypt = calls()[2]
    assert.is_truthy(
      encrypt:find('ansible-vault encrypt --output ' .. file, 1, true)
    )
    assert.is_truthy(encrypt:find('--encrypt-vault-id prod', 1, true))
    assert.equals('enc:db_password: x', vim.fn.readfile(file)[2])
  end)

  it('opens a chezmoi source file through chezmoi', function()
    local file = dir .. '/encrypted_private_dot_netrc.age'
    h.write(file, { 'age:machine example.com', 'age:password hunter2' })
    local bufnr = open(file)
    assert.same(
      { 'machine example.com', 'password hunter2' },
      vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    )
    assert.equals(
      'decrypted with chezmoi',
      require('util.sensitive').marked(bufnr)
    )
    vim.api.nvim_buf_set_lines(bufnr, 1, 2, false, { 'password changed' })
    vim.cmd('write')
    assert.same(
      { 'age:machine example.com', 'age:password changed' },
      vim.fn.readfile(file)
    )
    assert.is_truthy(
      calls()[2]:find('^chezmoi encrypt %-%-output ' .. vim.pesc(file))
    )
  end)

  it('leaves the ciphertext as it is when decryption fails', function()
    tool('sops', { 'echo "no key could decrypt the data" >&2', 'exit 128' })
    local file = dir .. '/values.yaml'
    h.write(file, { 'a: ENC[AES256_GCM,data:x]', 'sops:' })
    local bufnr, decrypted = open(file)
    assert.is_false(decrypted)
    assert.same(
      { 'a: ENC[AES256_GCM,data:x]', 'sops:' },
      vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    )
    assert.are_not.equal('acwrite', vim.bo[bufnr].buftype)
    assert.is_truthy(
      notes[#notes]:find('no key could decrypt the data', 1, true)
    )
  end)

  it('never writes the clear text when encryption fails', function()
    local file = dir .. '/encrypted_dot_token.age'
    h.write(file, { 'age:secret' })
    local bufnr = open(file)
    tool('chezmoi', { 'echo "no recipients" >&2', 'exit 1' })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'other' })
    vim.cmd('silent! write')
    assert.same({ 'age:secret' }, vim.fn.readfile(file))
    assert.is_true(vim.bo[bufnr].modified)
    assert.is_truthy(notes[#notes]:find('Not written: no recipients', 1, true))
  end)

  it('leaves an ordinary file alone', function()
    local file = dir .. '/plain.yaml'
    h.write(file, { 'a: 1' })
    local _, decrypted = open(file)
    assert.is_false(decrypted)
    assert.equals(0, vim.fn.filereadable(log))
  end)

  describe('diff', function()
    local repo

    --- `git` in the scratch repository
    local function git(...)
      local result = vim
        .system(
          vim.list_extend(
            { 'git', '-c', 'user.name=t', '-c', 'user.email=t@t' },
            { ... }
          ),
          { cwd = repo }
        )
        :wait()
      assert.equals(0, result.code, result.stderr)
    end

    before_each(function()
      repo = dir .. '/repo'
      vim.fn.mkdir(repo, 'p')
      git('init', '-q')
      h.write(repo .. '/values.yaml', {
        'plain: password: old',
        'x: ENC[AES256_GCM,data:x]',
        'sops:',
      })
      git('add', 'values.yaml')
      git('commit', '-q', '-m', 'first')
      h.write(repo .. '/values.yaml', {
        'plain: password: new',
        'x: ENC[AES256_GCM,data:x]',
        'sops:',
      })
    end)

    it('diffs the clear text with the one at HEAD, held back', function()
      local bufnr = open(repo .. '/values.yaml')
      assert.same(
        { 'password: new' },
        vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      )

      encrypted.command({ fargs = {} })
      -- The cursor is back on the buffer being edited, the old text beside it
      assert.equals(bufnr, vim.api.nvim_get_current_buf(), vim.inspect(notes))
      local wins = vim.api.nvim_tabpage_list_wins(0)
      assert.equals(2, #wins)
      local scratch = vim.api.nvim_win_get_buf(wins[1])
      assert.same(
        { 'password: old' },
        vim.api.nvim_buf_get_lines(scratch, 0, -1, false)
      )
      assert.is_truthy(require('util.sensitive').marked(scratch))
      assert.equals('nofile', vim.bo[scratch].buftype)
      assert.is_false(vim.bo[scratch].swapfile)
      assert.is_false(vim.bo[scratch].modifiable)
      assert.is_true(vim.wo[vim.fn.bufwinid(scratch)].diff)
      assert.is_true(vim.wo[vim.fn.bufwinid(bufnr)].diff)

      -- The copy sops read is gone, with the directory it was put in
      local decrypted = vim.tbl_filter(
        function(line) return line:match('^sops decrypt .*/values%.yaml$') end,
        calls()
      )
      local copy = decrypted[#decrypted]:match('^sops decrypt (.*)$')
      assert.are_not.equal(repo .. '/values.yaml', copy)
      assert.equals(0, vim.fn.filereadable(copy))
      assert.equals(0, vim.fn.isdirectory(vim.fs.dirname(copy)))
    end)

    it('leaves diff mode once the old text is closed', function()
      local bufnr = open(repo .. '/values.yaml')
      encrypted.diff(bufnr)
      local wins = vim.api.nvim_tabpage_list_wins(0)
      local scratch_win = wins[1]
      assert.are_not.equal(bufnr, vim.api.nvim_win_get_buf(scratch_win))
      vim.api.nvim_win_close(scratch_win, true)
      assert.is_true(
        vim.wait(
          1000,
          function() return not vim.wo[vim.fn.bufwinid(bufnr)].diff end,
          10
        )
      )
    end)

    it('says when the file is not in git at the revision', function()
      h.write(repo .. '/new.yaml', {
        'plain: a',
        'x: ENC[AES256_GCM,data:x]',
        'sops:',
      })
      local bufnr = open(repo .. '/new.yaml')
      encrypted.diff(bufnr)
      assert.equals(bufnr, vim.api.nvim_get_current_buf())
      assert.is_truthy(
        notes[#notes]:find('new.yaml is not in git at HEAD', 1, true)
      )
    end)

    it('refuses a buffer that was not decrypted', function()
      vim.cmd.edit(repo .. '/plain.txt')
      encrypted.diff(0)
      assert.equals('This buffer is not a decrypted file', notes[#notes])
    end)

    it('maps <localleader>D on a decrypted buffer', function()
      local bufnr = open(repo .. '/values.yaml')
      local map = vim.fn.maparg('<localleader>D', 'n', false, true)
      assert.equals(bufnr, map.buffer == 1 and bufnr or -1)
    end)
  end)
end)
