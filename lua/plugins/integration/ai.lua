-- `agy` has no ACP mode of its own. Google publishes an ACP server for it in
-- the ACP registry, as a binary archive, which is installed here.
local agy_acp = {
  version = '1.2.1',
  dir = vim.fn.stdpath('data') .. '/agy-acp',
}
agy_acp.cmd = agy_acp.dir .. '/agy_acp_server.par'

--- Download Google's ACP server for Antigravity into `agy_acp.dir`
local function install_agy_acp()
  local uname = vim.uv.os_uname()
  local system = ({ Darwin = 'macos', Linux = 'linux' })[uname.sysname]
  local arch = ({ arm64 = 'arm64', aarch64 = 'arm64', x86_64 = 'x86_64' })[uname.machine]
  if not system or not arch then
    error(
      'agy ACP server: no build for ' .. uname.sysname .. ' ' .. uname.machine
    )
  end
  local url = string.format(
    'https://dl.google.com/agy-extensions/releases/%s/agy-acp-server-%s-%s-%s.zip',
    system,
    agy_acp.version,
    system == 'macos' and 'darwin' or 'linux',
    arch
  )
  local zip = agy_acp.dir .. '.zip'
  vim.fn.mkdir(agy_acp.dir, 'p')
  for _, cmd in ipairs({
    { 'curl', '-fsSL', '-o', zip, url },
    { 'unzip', '-o', '-q', zip, '-d', agy_acp.dir },
  }) do
    local result = vim.system(cmd, { text = true }):wait()
    if result.code ~= 0 then
      error(table.concat(cmd, ' ') .. ': ' .. (result.stderr or ''))
    end
  end
  vim.fn.delete(zip)
end

return {
  {
    -- Copilot with native LSP
    import = 'lazyvim.plugins.extras.ai.copilot-native',
  },
  {
    -- Keep Copilot out of files holding credentials
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        copilot = {
          -- nvim-lspconfig ships Copilot with `telemetryLevel = 'all'`.
          settings = {
            telemetry = {
              telemetryLevel = 'off',
            },
          },
          -- Copilot attaches to every filetype, and attaching alone sends the
          -- buffer's text to GitHub. A `root_dir` function that never calls
          -- `on_dir` is how a buffer is declined before the client starts,
          -- and with no client attached neither inline completion nor
          -- sidekick's next edit suggestions have anything to send to.
          -- `on_dir()` without a root leaves `root_markers` to find it.
          root_dir = function(bufnr, on_dir)
            if not require('util.sensitive').is_sensitive(bufnr) then
              on_dir()
            end
          end,
        },
      },
    },
  },
  {
    -- AI CLI
    import = 'lazyvim.plugins.extras.ai.sidekick',
  },
  {
    -- Antigravity CLI integration
    'folke/sidekick.nvim',
    opts = {
      cli = {
        tools = {
          antigravity = {
            cmd = { 'agy' },
            is_proc = '\\<agy\\>',
            url = 'https://antigravity.google/docs/cli-overview',
            resume = { '--continue' },
            continue = { '--continue' },
            format = function(text)
              require('sidekick.text').transform(
                text,
                function(str)
                  return str:find('[^%w/_%.%-]') and ('"' .. str .. '"') or str
                end,
                'SidekickLocFile'
              )
            end,
          },
        },
      },
    },
  },
  {
    -- Claude Code
    import = 'lazyvim.plugins.extras.ai.claudecode',
  },
  {
    -- LLMs & Agents
    'yetone/avante.nvim',
    build = {
      -- The ACP adapters Avante talks to Claude Code and Codex through. They
      -- come first: a failed step stops the rest, and `make` is the slow one.
      vim.fn.executable('mise') == 1
          and 'mise use -g npm:@zed-industries/claude-agent-acp@latest npm:@zed-industries/codex-acp@latest'
        or 'npm install -g @zed-industries/claude-agent-acp@latest @zed-industries/codex-acp@latest',
      install_agy_acp,
      'make',
    },
    cmd = {
      'AvanteAsk',
      'AvanteChat',
      'AvanteChatNew',
      'AvanteClear',
      'AvanteEdit',
      'AvanteFocus',
      'AvanteHistory',
      'AvanteModels',
      'AvanteRefresh',
      'AvanteStop',
      'AvanteSwitchProvider',
      'AvanteToggle',
      'AvanteACPModels',
      'AvanteACPModes',
      'Avante',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      {
        'ColinKennedy/mega.cmdparse',
        dependencies = { 'ColinKennedy/mega.logging' },
      },
      'ravitemer/mcphub.nvim', -- MCP Hub
    },
    config = function(_, opts)
      -- The sidebar only collapses fully with a global statusline
      vim.o.laststatus = 3
      -- A `config` of its own replaces lazy.nvim's call to `setup`, which
      -- left every option above unread and Avante half started.
      require('avante').setup(opts)
    end,
    opts = {
      provider = vim.env.VIM_AVANTE_PROVIDER or 'claude-code',
      providers = {
        copilot = {
          model = vim.env.VIM_AVANTE_MODEL or 'claude-sonnet-4.6',
        },
        -- Avante leaves Ollama off; it is on whenever a server answers
        ollama = {
          endpoint = vim.env.VIM_AVANTE_OLLAMA_ENDPOINT
            or 'http://127.0.0.1:11434',
          model = vim.env.VIM_AVANTE_OLLAMA_MODEL or 'qwen-7b-instruct',
          is_env_set = function()
            return require('avante.providers.ollama').check_endpoint_alive()
          end,
        },
      },
      acp_providers = {
        ['claude-code'] = {
          command = 'claude-agent-acp',
          args = {},
          env = {
            NODE_NO_WARNINGS = '1',
            -- Unset, Claude Code uses its own login
            ANTHROPIC_API_KEY = vim.env.ANTHROPIC_API_KEY,
            ANTHROPIC_BASE_URL = vim.env.ANTHROPIC_BASE_URL,
            ANTHROPIC_MODEL = vim.env.VIM_AVANTE_CLAUDE_MODEL
              or 'claude-opus-5-5',
            ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.exepath('claude'),
            -- Avante's default is `bypassPermissions`, which runs every tool
            -- of Claude Code unasked. Its shell and search read the disk
            -- without going through Avante, so they are asked for instead.
            ACP_PERMISSION_MODE = 'default',
          },
        },
        -- `codex` is one of Avante's own entries, run through `codex-acp`; it
        -- signs in with Codex's login, or `OPENAI_API_KEY`.
        -- Google's server signs in as chosen in
        -- `~/.gemini/antigravity-acp/settings.json`.
        agy = {
          command = agy_acp.cmd,
          args = vim.uv.os_uname().sysname == 'Linux' and { '--uid=' } or {},
        },
      },
      behaviour = {
        -- The defaults bind the whole `<leader>a` group, over the keys of
        -- sidekick and Claude Code. The ones kept are under `keys` below.
        auto_set_keymaps = false,
        -- Avante runs every tool without asking by default. Reading, and
        -- editing inside the project, goes through on its own; a shell, a
        -- deletion, or anything reaching past the project is asked for.
        auto_approve_tool_permissions = {
          -- Claude Code's requests are matched by their ACP kind; `think` is
          -- also the name of Avante's own tool
          'read',
          'search',
          'think',
          'edit',
          -- Avante's own tools, by name

          'attempt_completion',
          'get_diagnostics',
          'git_diff',
          'glob',
          'grep',
          'ls',
          'read_definitions',
          'read_file_toplevel_symbols',
          'read_todos',
          'view',
          'write_todos',
          'create_dir',
          'edit_file',
          'insert',
          'str_replace',
          'undo_edit',
          'write_to_file',
        },
      },
      selection = {
        hint_display = 'none',
      },
      input = {
        provider = 'snacks',
      },
      selector = {
        provider = 'snacks',
      },
      -- A function, so the running MCP servers are read on every message.
      -- Only Avante's own providers read this and `custom_tools`: Claude
      -- Code brings its own prompt, tools and MCP servers.
      system_prompt = function()
        local ok, mcphub = pcall(require, 'mcphub')
        local hub = ok and mcphub.get_hub_instance() or nil
        return hub and hub:get_active_servers_prompt() or ''
      end,
      custom_tools = function()
        local ok, mcphub = pcall(require, 'mcphub.extensions.avante')
        return ok and { mcphub.mcp_tool() } or {}
      end,
    },
    keys = {
      {
        '<leader>ac',
        function() require('avante').toggle() end,
        desc = 'Avante Toggle Chat',
      },
      {
        'ga',
        function() require('avante.api').ask() end,
        mode = { 'v' },
        desc = 'Ask Avante about Selection',
      },
      {
        '<leader>aC',
        '<cmd>AvanteChatNew<cr>',
        desc = 'Avante New Chat',
      },
      {
        '<leader>aI',
        '<cmd>AvanteEdit<cr>',
        mode = { 'n', 'v' },
        desc = 'Avante Inline Edit',
      },
      {
        '<leader>ah',
        '<cmd>AvanteHistory<cr>',
        desc = 'Avante History',
      },
      {
        '<leader>am',
        '<cmd>AvanteModels<cr>',
        desc = 'Avante Select Model',
      },
      {
        '<leader>aM',
        '<cmd>AvanteACPModels<cr>',
        desc = 'Avante Select Agent Model',
      },
      {
        '<leader>aP',
        '<cmd>AvanteSwitchProvider<cr>',
        desc = 'Avante Switch Provider',
      },
    },
  },
  {
    -- Completion of `@` mentions and `/` commands in Avante's prompt
    'blink.cmp',
    dependencies = {
      'Kaiser-Yang/blink-cmp-avante',
      init = function()
        _G.completion_sources =
          vim.tbl_extend('force', _G.completion_sources or {}, {
            Avante = '「AI」',
          })
      end,
    },
    opts = {
      sources = {
        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
          },
        },
        per_filetype = {
          -- Path sources triggered by "/" would hide Avante's commands
          AvanteInput = { 'avante', 'buffer', 'emoji', 'dictionary' },
        },
      },
    },
  },
  {
    -- MCP Hub integration for AI tools
    'ravitemer/mcphub.nvim',
    enabled = vim.fn.executable('npm') == 1,
    build = vim.fn.executable('mise') == 1 and 'mise use -g npm:mcp-hub@latest'
      or 'npm install -g mcp-hub@latest',
    opts = {
      auto_approve = true,
      auto_toggle_mcp_servers = false,
      extensions = {
        avante = {
          make_slash_commands = true,
        },
      },
      ui = {
        window = {
          border = vim.o.winborder,
        },
      },
    },
    keys = {
      {
        '<leader>M',
        '<cmd>MCPHub<CR>',
        desc = 'MCPHub',
      },
    },
  },
}
