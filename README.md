# DyNeo

> A Neovim configuration that turns the editor into a DevOps and SA
> workstation — every language declared in one table, and not a single tool
> installed until a file asks for it.

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.13-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![Built on lazy.nvim](https://img.shields.io/badge/built%20on-lazy.nvim-blueviolet.svg?style=flat-square)](https://lazy.folke.io)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)

*DyNeo* is *đi nào* — Vietnamese for "let's go" — and *Dy* (from dynamo, the
author's handle) plus *Neo*vim. It is a standalone
[lazy.nvim](https://lazy.folke.io) configuration, not a distribution. The same
tree runs on a laptop with everything on and in a container with four
languages; only a few globals differ.

<!-- toc -->

- [Highlights](#highlights)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Languages, Frameworks, or Tools support](#languages-frameworks-or-tools-support)
- [Features](#features)
- [Key bindings](#key-bindings)
- [Commands](#commands)
- [Repository layout](#repository-layout)
- [Development](#development)
- [Benchmark](#benchmark)

<!-- tocstop -->

## Highlights

- 🧩 **One entry per language** in
  [lua/config/languages.lua](./lua/config/languages.lua): parser, servers,
  linters, formatters, debug adapters, test runners.
- 🪶 **Nothing eager.** A single `FileType` dispatcher installs a language's
  tooling the first time one of its files is opened; startup stays in the
  tens of milliseconds.
- 🔒 **Supply-chain aware.** Mason packages and plugin updates wait a week
  after release, updates can be reviewed before they land, and what is
  installed can be exported as an SBOM and checked against OSV.
- 🤖 **AI with a guard rail.** Secrets are kept from every AI integration, and
  what each one was handed is logged.
- 🛟 **Two channels.** `latest` follows plugin `main` on Neovim nightly;
  `stable` takes tagged releases. Each has its own lockfile.
- 🧪 **Tested.** plenary-busted specs, a startup check that opens a file of
  every language, and CI on both channels.

> [!CAUTION]
>
> Neovim only: 0.13+ on `latest`, 0.12+ on `stable`. `latest` can break with
> any `:Lazy update`; use `DyNeo.plugin_channel = 'stable'` where it must not.
> Used on Linux and macOS.

## Quick start

| Needed for | Programs |
| ---------- | -------- |
| Running at all | **Neovim 0.13+** (nightly), or 0.12+ on `stable` |
| Plugins | **git** |
| Icons | a [Nerd Font](https://www.nerdfonts.com/) |
| Mason downloads | **curl**, **tar**, **unzip**, **gzip** |
| Treesitter parsers | a **C compiler**, the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli) |
| Pickers and completion | **ripgrep**, **fd** |

Everything else is installed lazily, through whichever toolchains are on
`PATH` (node or bun, python or uv, go, cargo, java…). Tools marked
`mason = { enabled = false }` in `languages.lua` (`rustfmt`, `tofu`, `zig`,
`nix`…) must come from the system; a missing one is skipped. Optional:
`pngpaste`/`wl-paste`/`xclip` to paste images, `fcitx5-remote` for input
methods, `d2` and a kitty-graphics terminal for diagrams.

```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://gitlab.com/dynamo-config/neovim.git ~/.config/nvim --single-branch --depth 1
# or beside an existing config:
git clone https://gitlab.com/dynamo-config/neovim.git ~/.config/dynamo --single-branch --depth 1
NVIM_APPNAME=dynamo nvim
```

The first start clones the plugins; the first file of a language installs its
tooling. Then try `:Lazy`, `:Mason`, `:checkhealth dyneo`, and `<Space>` to
let which-key list everything.

## Configuration

Override the defaults of [lua/config/globals.lua](./lua/config/globals.lua) in
`lua/per_machine/config.lua`, loaded before anything else (chezmoi renders it
from `config.lua.tmpl` on my machines; without it the defaults stand):

```lua
DyNeo.plugin_channel = 'stable'
DyNeo.enabled_languages = { 'lua', 'bash', 'markdown' }
DyNeo.enabled_plugins.obsidian = true
```

| Global | Default | What it does |
| ------ | ------- | ------------ |
| `DyNeo.dark_mode` | `true` | Background, when the clock is not in charge |
| `DyNeo.day_night` | `{ enabled = false, day_start = 6, night_start = 18 }` | Let the clock drive `dark_mode` |
| `DyNeo.plugin_channel` | `'latest'` | `latest` (newest commits, `lazy-lock.json`) or `stable` (releases, `lazy-lock.stable.json`) |
| `DyNeo.quarantine_window` | one week | How long a release waits before it may be installed; `0` turns it off |
| `DyNeo.enabled_languages` | all | Languages that get plugins, parsers and tools |
| `DyNeo.bundle_languages` | `{}` | Languages installed up front, for containers |
| `DyNeo.enabled_plugins` | all `false` | `obsidian`, `leetcode`, `otter`, `firenvim`, `chezmoi` |
| `DyNeo.used_full_plugins` | `false` | Install every plugin, to refresh the lockfile |
| `DyNeo.is_gentoo` | `false` | Gentoo ebuild syntax |
| `DyNeo.obsidian.paths` | `{ personal = '~/Documents/Notes' }` | Vault name to folder |
| `DyNeo.yaml_schema_dirs` | `{}` | Local schema folders for the YAML schema picker |
| `DyNeo.dictionaries_path` | `$XDG_CONFIG_HOME/dictionaries` | Word lists for completion and `:DySpell` |
| `DyNeo.dev_plugins_path` | `$NVIM_DEV_PLUGINS` or `~/Working/community/nvim` | Where `dev = true` plugins are looked for |
| `DyNeo.firenvim_site_settings` | `{}` | Per-site rules for firenvim |
| `DyNeo.test_strategy` | `'toggleterm'`, `'zellij'` inside zellij | How vim-test runs a test |
| `DyNeo.completion_sources` | `{}` | Source names shown in the completion menu |

**Updating plugins.** Commit the lockfile, `:Lazy update`, commit again once
everything works. To roll back, `git restore lazy-lock.json` and `:Lazy
restore`.

## Languages, Frameworks, or Tools support

103 entries over 126 filetypes; the list is
[lua/config/languages.lua](./lua/config/languages.lua).

<details>
<summary>42 languages</summary>

Arduino, AWK, Bash (with Arch and Gentoo build recipes), C/C++, C#, Clojure,
CSS/Less, Cucumber, Dart, Elixir, Erlang, Fish, GDScript, GDShader, Gleam, Go,
GraphQL, Haskell, HTML, Java, Javascript/Typescript, Julia, Kotlin, LaTeX,
Lua, Nushell, OCaml, Perl, PHP, Python, R, Ruby, Rust, SASS/SCSS, Scala,
Solidity, SQL, Swift, Typst, Vimscript, Zig, Zsh.

</details>

<details>
<summary>13 frameworks</summary>

Angular, Astro, Django templates, Ember (Handlebars), Laravel (Blade), Phoenix
(HEEx), Qt (QML), Rails, Rust, Svelte, Symfony (Twig), Templ, Vue.

</details>

<details>
<summary>38 tools and markup languages</summary>

Ansible, Beancount, Bicep, CMake, CSV, CUE, D2, DBML, Dockerfile, Git (rebase,
commit), GoTemplate (Helm…), Groovy (Jenkinsfile), HTTP, Hurl, Hyprlang,
Jinja, jq, JSON, Jsonnet, Just, KDL, Make (autoconf, automake), Markdown,
Mermaid, Nginx, Nix, Prisma, PromQL, Protobuf, Rego, SystemD, Terraform,
Terragrunt, TOML, Treesitter, XML, YAML, Yuck.

</details>

## Features

**Tooling that installs itself.** Opening a Go file installs the Go parser,
`gopls`, its linters, formatters and `delve`, through one `FileType`
dispatcher ([lua/util/lazy_install.lua](./lua/util/lazy_install.lua)). A tool
Mason has no package for is installed by `dytoy` and linked in
([lua/tools/mason-dytoy.lua](./lua/tools/mason-dytoy.lua)).

**Quarantine.** Mason's registry snapshot and every plugin update are held to
releases older than `DyNeo.quarantine_window`, like npm, bun, pnpm and uv
elsewhere in these dotfiles; Mason's npm and PyPI installs also go through
[Socket Firewall](https://socket.dev). `:LazyQuarantine` lists what is held
back; `:LazyQuarantine review` shows the commits each update brings and flags
added lines that run processes, load code, reach the network, touch
credentials, delete files or change the build. `:DySbom` exports the plugins
and Mason packages as CycloneDX, and `:DySbom osv` checks them against
[OSV](https://osv.dev).

**Files that never reach an AI.** `.env` files, keys and credential stores
([lua/config/sensitive.lua](./lua/config/sensitive.lua)), and any buffer whose
text looks like a token (or that `betterleaks` flags), are kept from Copilot,
Avante, sidekick and Claude Code. `camouflage.nvim` masks them on screen.
`:AiGuardCheck` says why a buffer is held back, `:AiGuardAllow[!]` waives the
content check or takes the waiver back, and `:AiGuardLog[!]` lists what each
integration was handed or refused — paths and times, never the text.

**YAML and JSON schemas.** Detected from the buffer (Kubernetes, CRDs,
cloud-init); `<leader>cys` or `:YamlSchema` picks one from the catalogs, the
project or `DyNeo.yaml_schema_dirs`.

**What is attached.** The statusline counts servers and tools;
`<leader>cL` and `<leader>cT` list them and whether each is installed,
running or missing.

**Spelling.** `:DySpell {lang}` builds Vietnamese, Chinese, `proper` and
`technical` spell files; comments are checked through
[ltcc](https://github.com/dynamotn/languagetool-code-comments).

**Previews.** `<leader>cp` renders the D2 diagram under the cursor inline on a
kitty-graphics terminal, and previews Markdown and Typst.

**Workspace diagnostics.** `<leader>xw` hands the language server every file
of the project, read off the main loop.

**Tasks.** `<leader>oo` offers overseer tasks for the current file in about 50
languages ([lua/config/tasks.lua](./lua/config/tasks.lua)), plus the
project's build and test tasks.

**Runbooks.** In Markdown, `<localleader>r` runs the code block under the
cursor (`sh`, `bash`, `zsh`, `fish`, `console`, `python`, `js`) and writes its
output in an `output` fence below; `R` runs them all and stops at the first
failure, `x` clears outputs, `s` stops. `sudo`, `rm -rf`, `kubectl delete`,
`destroy` and the like ask first.

**Gaps filled** in [lua/tools](./lua/tools) and [lua/lint](./lua/lint): Jira
completion in commit messages, shellcheck code actions, sonarlint connected
mode, LanguageTool for comments, nvim-lint definitions for `betterleaks`,
`dyshellint` and `d2`, `terragrunt validate`, and rule ids for
`nvim-rulebook`.

**Integrations.**

- [Obsidian](https://obsidian.md/) vaults, [chezmoi](https://www.chezmoi.io/)
  templates with the target language injected,
  [firenvim](https://github.com/glacambre/firenvim) in the browser, and
  [zellij](https://zellij.dev/) for tests, terminals and completion.
- AI CLIs through [sidekick](https://github.com/folke/sidekick.nvim), behind
  the guard.
- GitHub through [Octo](https://github.com/pwntester/octo.nvim) when `gh` is
  installed; GitLab merge requests through
  [gitlab.nvim](https://github.com/harrisoncramer/gitlab.nvim) when `glab` is,
  with the token from `.gitlab.nvim`, `GITLAB_TOKEN` or `glab`, and the
  instance from the remote; CI checks on GitHub, GitLab or Forgejo.
- Jira through [jira-cli](https://github.com/ankitpokhrel/jira-cli): `:Jira`
  picks an issue to branch from, move, log work on, view or open; without one
  picked, the issue in the branch name is used.

## Key bindings

The leader is `Space`; which-key lists everything under it and `<Space>sk`
searches it. Every mapping is in
[doc/dyneo-keymaps.txt](./doc/dyneo-keymaps.txt) (`:help dyneo-keymaps`).
The ones worth knowing:

| Key | Mode | What |
| --- | ---- | ---- |
| `<leader>fy` | n | Copy the file path: relative, absolute, with line or column, directory, root |
| `<leader>cL`, `<leader>cT` | n | Servers, formatters and linters of the buffer |
| `<leader>cys`, `<leader>cym` | n | Pick a YAML schema, or write it as a modeline |
| `<leader>cp` | n | Preview the diagram, Markdown or Typst |
| `<leader>xw` | n | Workspace diagnostics |
| `<leader>pc` | n | CI checks of the branch |
| `<leader>ph` | n | GitHub (Octo) |
| `<leader>pl` | n | GitLab merge requests |
| `<leader>pj` | n | Jira |
| `<leader>ps` | n | Project LSP settings (codesettings) |
| `<leader>a` | n, x | AI CLIs; Claude Code at `<leader>ac`, Avante at `<leader>av` |
| `<leader>uk` | n | Mask the values of a secret file |
| `<leader>ct` | n | Translate |
| `<leader>yh`, `<leader>yi` | n, x | Yank history, paste an image |
| `<leader>v` | n, x | Multiple cursors |
| `d`, `x`, `c`, `C`, `X` | n, v | A blank line goes to the black hole register |
| `/`, `<C-f>`, `<C-r>` | x | Search inside, search for, replace the selection |
| `:W`, `:Q`, `:Wq`, `:Qa`, `:ww` | c | The typo you meant; `:ww` saves through `sudo tee` |

## Commands

| Command | What |
| ------- | ---- |
| `:LazyQuarantine [review [{plugin}]]` | Plugins held back; or what their updates bring, flagged |
| `:DySbom [{path}\|osv]` | Plugins and Mason packages as CycloneDX; or their known vulnerabilities |
| `:AiGuardCheck`, `:AiGuardAllow[!]`, `:AiGuardLog[!]` | Why a buffer is kept from AI; waive it; what was sent |
| `:YamlSchema [modeline\|reset] [{path}]` | Set the schema of a YAML buffer |
| `:DyNeoFormat`, `:DyNeoFormatInfo` | Format; which formatters would run |
| `:DyNeoRoot` | The roots found for this buffer |
| `:DySpell {lang}` | Rebuild a spell file |
| `:Runbook [run\|all\|clear\|stop]` | Run the Markdown code blocks |
| `:Jira [search {jql}\|{action} [{key}]]` | Pick an issue, or `branch`, `move`, `worklog`, `view`, `open`, `insert`, `copy` |

`:help dyneo` covers the same ground inside Neovim.

## Repository layout

| Path | What it holds |
| ---- | ------------- |
| `init.lua` | Globals, per-machine overrides, the version gate, lazy.nvim |
| `lua/config/` | `globals`, `languages`, `tasks`, `options`, `keymaps`, `autocmds`, `sensitive` |
| `lua/plugins/` | Plugin specs by area |
| `lua/util/` | Helpers the specs call into |
| `lua/tools/` | Features built here: quarantines, plugin review, SBOM, Jira, runbooks, Mason registry, diagrams, workspace diagnostics |
| `lua/lint/`, `lua/overseer/` | nvim-lint definitions, task templates |
| `lua/per_machine/` | Per-machine overrides, rendered by chezmoi |
| `plugin/` | Commands defined at startup: AI guard, `:DySpell`, `:DySbom`, `:Jira`, `:Runbook` |
| `lsp/`, `ftplugin/`, `after/`, `queries/`, `snippets/`, `spell/`, `colors/`, `ftdetect/` | Runtime files |
| `scripts/`, `tests/` | Checks, benchmarks, the test runner; plenary-busted specs |
| `doc/` | Help file and generated mapping reference |

## Development

```sh
scripts/test.sh [path]                                 # unit tests, or one directory or spec
scripts/check-startup.sh                               # load everything, open a file of each language
nvim --clean --headless -l scripts/validate-tools.lua  # tool names against conform, nvim-lint, lspconfig, Mason
scripts/keymaps-doc.sh                                 # regenerate doc/dyneo-keymaps.txt
pre-commit run --all-files                             # all of it, plus stylua
```

`:checkhealth dyneo` checks the machine itself: Neovim version, parser build
tools, the quarantine, the AI guard, and missing programs. After editing
[doc/dyneo.txt](./doc/dyneo.txt), run `:helptags doc`.

## Benchmark

```bash
nvim --clean --headless -l scripts/bench.lua            # starting Neovim
nvim --clean --headless -l scripts/bench-filetypes.lua  # opening a file of each filetype
```

Both rewrite their section below when a number moves past a threshold
(`BENCH_FORCE=1`, `BENCH_FT_FORCE=1` to force; `BENCH_FT_ONLY=lua,go` to time
a few). Single filetype rows are noisy, up to 2.7x between runs: compare
before and after with the same command, not against this table.

<!-- bench:start -->
<!-- Generated by scripts/bench.lua; edit that, not this. -->

Measured with `nvim --startuptime` over 10 runs on AMD Ryzen 9 5950X 16-Core Processor (Linux x86_64), Neovim 0.13.0, 2026-10-08.

| Command | Median | Mean ± σ | Min | Max | Wall clock |
| ------- | -----: | -------: | --: | --: | ---------: |
| `nvim --headless +q` | 44.0 ms | 44.3 ± 1.7 ms | 42.1 ms | 48.3 ms | 47.5 ms |
| `nvim --headless README.md +q` | 386.7 ms | 387.5 ± 2.9 ms | 383.8 ms | 392.5 ms | 484.6 ms |
| `nvim --headless init.lua +q` | 159.3 ms | 158.7 ± 5.3 ms | 149.0 ms | 165.5 ms | 218.8 ms |

Slowest steps of `nvim --headless +q` (self + sourced, mean):

```
step                            time percent  plot
init.lua                       40.90   92.28  ████████████████████████
config.lazy                    39.70   89.58  ███████████████████████▎
catppuccin.vim                  2.34    5.29  █▍
vim.filetype                    1.64    3.69  █
catppuccin                      1.63    3.67  █
lazy.core.handler.event         1.22    2.75  ▊
config.globals                  1.06    2.38  ▋
filetype.lua                    0.97    2.19  ▋
config.options                  0.97    2.19  ▋
lazy.core.loader                0.95    2.14  ▌
```
<!-- bench:end -->

<!-- bench-filetypes:start -->
<!-- Generated by scripts/bench-filetypes.lua; edit that, not this. -->

### Filetypes

Opening a file of each of the 126 filetypes, one Neovim per filetype, fastest of 4 runs on AMD Ryzen 5 7535HS with Radeon Graphics (Linux x86_64), Neovim 0.13.0, 2026-10-02.

| | `open` | `ready` | `reopen` | `plugins` |
| --- | -----: | ------: | -------: | --------: |
| median | 130.0 ms | 153.4 ms | 19.8 ms | 41 |
| 90th percentile | 161.2 ms | 191.1 ms | 33.5 ms | 43 |

`open` is the blocking `:edit`, `ready` runs on to the last plugin load or server attach it set off, and `reopen` is the same file once its filetype is loaded. `plugins` is how many lazy.nvim loaded for it, and is the same number every run where the milliseconds are not: two sweeps of the same tree put a single filetype anywhere from 0.6x to 2.7x of each other here, so read a row as an order of magnitude and the summary above as the figure that moves when something real does.

The 15 slowest to open:

| Filetype | Open | Ready | Reopen | Plugins | Language |
| -------- | ---: | ----: | -----: | ------: | -------- |
| `jsonc` | 297.5 ms | 335.8 ms | 31.4 ms | 41 | json |
| `java` | 285.0 ms | 321.7 ms | 40.3 ms | 75 | java |
| `json.openapi` | 280.9 ms | 314.1 ms | 29.7 ms | 41 | json |
| `json` | 275.1 ms | 310.4 ms | 33.8 ms | 41 | json |
| `php` | 219.9 ms | 251.2 ms | 47.6 ms | 47 | php |
| `markdown` | 219.2 ms | 263.5 ms | 62.9 ms | 41 | markdown |
| `astro` | 216.9 ms | 253.9 ms | 67.9 ms | 41 | astro |
| `plaintex` | 180.9 ms | 202.3 ms | 68.0 ms | 41 | latex |
| `tex` | 179.7 ms | 208.4 ms | 65.2 ms | 41 | latex |
| `eruby` | 175.2 ms | 196.2 ms | 46.9 ms | 41 | rails |
| `ruby` | 167.9 ms | 191.1 ms | 30.0 ms | 42 | ruby |
| `haskell` | 163.8 ms | 192.8 ms | 27.3 ms | 47 | haskell |
| `julia` | 161.2 ms | 190.6 ms | 17.0 ms | 43 | julia |
| `clojure` | 161.1 ms | 252.7 ms | 18.4 ms | 47 | clojure |
| `html` | 160.8 ms | 184.1 ms | 35.0 ms | 41 | html |

Opened as another filetype, and timed under the one asked for: `plaintex` as `tex`, `ipynb` as `python`.
<!-- bench-filetypes:end -->
