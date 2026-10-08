# neovim-config

> A Neovim configuration that turns the editor into a DevOps and SA
> workstation — every language declared in one table, and not a single tool
> installed until a file asks for it.

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.13-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![Built on lazy.nvim](https://img.shields.io/badge/built%20on-lazy.nvim-blueviolet.svg?style=flat-square)](https://lazy.folke.io)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)

This is DyNeo, a standalone [lazy.nvim](https://lazy.folke.io) configuration,
not a distribution to install over yours. Every language it knows about is one declarative entry
in [lua/config/languages.lua](./lua/config/languages.lua) — its Treesitter
parser, LSP servers, linters, formatters, debug adapters and test runners —
and a single `FileType` dispatcher installs that entry the first time a file
of the language is opened. Starting Neovim stays in the tens of milliseconds
because nothing above `init.lua` runs until a buffer asks for it.

The same tree runs on a laptop with everything enabled and in a container with
four languages; what differs is a handful of globals, see
[Per machine settings](#per-machine-settings).

<!-- toc -->

- [Why this configuration](#why-this-configuration)
- [Quick start](#quick-start)
  - [Requirements](#requirements)
  - [Install](#install)
  - [First start](#first-start)
- [Configuration](#configuration)
  - [Per machine settings](#per-machine-settings)
  - [Globals](#globals)
  - [Plugin channels](#plugin-channels)
  - [Updating plugins](#updating-plugins)
- [Languages, Frameworks, or Tools support](#languages-frameworks-or-tools-support)
  - [Languages](#languages)
  - [Frameworks](#frameworks)
  - [Tools & Markup](#tools--markup)
- [Beyond the defaults](#beyond-the-defaults)
  - [Tooling that installs itself](#tooling-that-installs-itself)
  - [A quarantine in front of Mason and lazy.nvim](#a-quarantine-in-front-of-mason-and-lazynvim)
  - [Files that never reach an AI](#files-that-never-reach-an-ai)
  - [Schemas for YAML and JSON](#schemas-for-yaml-and-json)
  - [What is attached to this buffer](#what-is-attached-to-this-buffer)
  - [Spelling, in several languages at once](#spelling-in-several-languages-at-once)
  - [Diagrams in the terminal](#diagrams-in-the-terminal)
  - [Workspace diagnostics](#workspace-diagnostics)
  - [Tools given what they lack](#tools-given-what-they-lack)
  - [Integrations](#integrations)
- [Key bindings](#key-bindings)
- [Commands](#commands)
- [Help inside Neovim](#help-inside-neovim)
- [Repository layout](#repository-layout)
- [Development](#development)
  - [Tests](#tests)
  - [Checks](#checks)
- [Benchmark](#benchmark)

<!-- tocstop -->

## Why this configuration

- 🧩 **One entry per language.** Parser, servers, linters, formatters, debug
  adapters, test runners, `dial` augends, autopairs rules — all of it in
  [lua/config/languages.lua](./lua/config/languages.lua), one table per
  language, nothing else to wire up.
- 🪶 **Nothing eager.** Treesitter parsers, LSP servers, linters, formatters
  and debug adapters are installed by Mason the first time one of their
  filetypes shows up, through a single `FileType` dispatcher rather than a few
  hundred autocmds.
- 🔒 **Supply-chain aware.** Every tool Mason installs, and every plugin update
  lazy.nvim offers, is held back for a week after its release — the same
  quarantine the surrounding dotfiles put on npm, bun, pnpm and uv.
- 🤖 **AI with a guard rail.** `.env` files, private keys and credential stores
  are kept out of every AI integration — not only Copilot's `root_dir`, but
  chats handed a file, selections following the cursor, and prompts on their
  way to a CLI tool.
- 🎛 **One tree, many machines.** A laptop, a workstation and a container run
  the same checkout and differ only in a few globals.
- 🛟 **Two speeds.** `latest` rides plugin `main` branches on a Neovim
  nightly; `stable` takes tagged releases on a released Neovim. Each keeps its
  own lockfile, so the two never overwrite each other's pins.
- 🧪 **Checked, not hoped for.** 42 plenary-busted spec files, a startup check
  that opens a file of every language, a tool-name validator, and CI that runs
  all of it on both channels.
- 📈 **Measured.** Two benchmarks — one for starting Neovim, one for opening a
  file — rewrite the [Benchmark](#benchmark) section themselves when a number
  really moves.

> [!CAUTION]
>
> - Neovim only. Not vim, at any version; not Neovim < 0.13 on the default
>   `latest` channel, or < 0.12 on `stable`.
> - The `latest` channel follows the newest Neovim and the newest plugin
>   commits, so an upstream break can land with any `:Lazy update`. Set
>   `DyNeo.plugin_channel = 'stable'` on a machine that should not ride along.
> - Used on Linux and macOS.

## Quick start

### Requirements

| Needed for | Programs |
| ---------- | -------- |
| Running at all | **Neovim 0.13+** (nightly), or 0.12+ on the `stable` channel |
| Bootstrapping plugins | **git** |
| Icons | a [Nerd Font](https://www.nerdfonts.com/) in the terminal |
| Mason downloads | **curl**, **tar**, **unzip**, **gzip** |
| Treesitter parsers | a **C compiler**, and the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli) |
| Pickers and completion | **ripgrep**, **fd** |

Everything else is installed lazily. Many Mason packages are built by a
language toolchain, so what Mason can install depends on what is on `PATH`:
**node**/**npm** (or **bun**), **python3**/**pip** (or **uv**), **go**,
**cargo**, **java**, and so on. `bun` and `uv` are used in place of `npm` and
`pip` when they are installed.

Some tools are never installed by Mason and must come from the system (or the
language's own toolchain) to be used: `bean-check`/`bean-format` (Beancount),
`bicep`, `clang-tidy` (C/C++, Arduino), `cmake-format`, `dart`, `erlfmt`,
`fish`/`fish_indent`, `forge` (Solidity), `gawk`, `gleam`, `hurlfmt`, `just`,
`mix` (Elixir, HEEx), `nginxfmt.py`, `nix`, `statix`, `nufmt`, `perlcritic`,
`perltidy`, `prisma-lint`, `qmlformat`, `rustfmt`, `scalafmt`, `terragrunt`,
`tofu` (Terraform), `zig`, `zsh`, plus `curl`, `sed` and `git` for the generic
sources. They are the entries marked `mason = { enabled = false }` in
[lua/config/languages.lua](./lua/config/languages.lua); a missing one is
skipped, not reported as an error.

Optional extras:

- Pasting images: `pngpaste` on macOS, `wl-paste` or `xclip` on Linux.
- Input method switching on Linux: `fcitx5-remote` (skipped without it).
- D2 diagrams: `d2`, plus one of `rsvg-convert`, `resvg` or `magick`, and a
  kitty-graphics terminal.

### Install

Back up whatever is there and clone this repository to `~/.config/nvim`:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://gitlab.com/dynamo-config/neovim.git ~/.config/nvim --single-branch --depth 1
```

To try it beside an existing configuration instead of replacing it, clone
anywhere and run it under its own name:

```sh
git clone https://gitlab.com/dynamo-config/neovim.git ~/.config/dynamo --single-branch --depth 1
NVIM_APPNAME=dynamo nvim
```

### First start

The first `nvim` clones the plugins; the first file of a language installs
that language's parser, servers and tools. Both report progress, and neither
blocks the editor beyond the lazy.nvim bootstrap.

Worth opening right away:

- `:Lazy` — what is installed, what loaded, and how long each took.
- `:Mason` — the tool side of the same question.
- `:checkhealth dyneo` — what of the requirements above is missing.
- `<Space>` — hold it and [which-key](https://github.com/folke/which-key.nvim)
  lists everything underneath.

## Configuration

### Per machine settings

[chezmoi](https://www.chezmoi.io/) is not needed. It renders
[lua/per_machine/config.lua.tmpl](./lua/per_machine/config.lua.tmpl) into
`lua/per_machine/config.lua` on my machines; in a plain clone that file does
not exist, the loader stays quiet about it, and the defaults in
[lua/config/globals.lua](./lua/config/globals.lua) stand.

To change them, write `lua/per_machine/config.lua` by hand and assign the
globals there. `init.lua` loads it before anything else, so every global below
is still open to it:

```lua
DyNeo.dark_mode = false
DyNeo.plugin_channel = 'stable'
DyNeo.enabled_languages = { 'lua', 'bash', 'markdown' }
DyNeo.enabled_plugins.obsidian = true
DyNeo.obsidian.paths.personal = vim.fn.expand('~/Notes')
DyNeo.dictionaries_path = vim.fn.expand('~/.local/share/dictionaries')
```

An error raised inside that file is reported; only its absence is silent.

### Globals

Every global is a field of the one global table `DyNeo`, declared, typed and
defaulted in [lua/config/globals.lua](./lua/config/globals.lua).

| Global | Default | What it does |
| ------ | ------- | ------------ |
| `DyNeo.dark_mode` | `true` | Background to use, whenever the clock is not in charge |
| `DyNeo.day_night` | `{ enabled = false, day_start = 6, night_start = 18 }` | Let the clock drive `dark_mode`, and the colorscheme with it |
| `DyNeo.plugin_channel` | `'latest'` | `latest` or `stable`, see [Plugin channels](#plugin-channels) |
| `DyNeo.quarantine_window` | `7 * 24 * 60 * 60` | How long a release waits before Mason or lazy.nvim may install it; `0` turns the wait off |
| `DyNeo.enabled_languages` | every supported language | Which languages get plugins, parsers and tools at all |
| `DyNeo.bundle_languages` | `{}` | Languages whose tooling is installed up front, for containers and prebuilt images |
| `DyNeo.enabled_plugins` | all `false` | `obsidian`, `leetcode`, `otter`, `firenvim`, `chezmoi` |
| `DyNeo.used_full_plugins` | `false` | Install every plugin, to refresh the lockfile |
| `DyNeo.is_gentoo` | `false` | Add the Gentoo ebuild syntax |
| `DyNeo.obsidian.paths` | `{ personal = '~/Documents/Notes' }` | Vault name to folder |
| `DyNeo.yaml_schema_dirs` | `{}` | Local schema folders offered by the YAML schema picker |
| `DyNeo.dictionaries_path` | `$XDG_CONFIG_HOME/dictionaries` | Word lists for completion and `:DySpell` |
| `DyNeo.dev_plugins_path` | `$NVIM_DEV_PLUGINS`, else `~/Working/community/nvim` | Where `dev = true` plugin specs are looked for |
| `DyNeo.firenvim_site_settings` | `{}` | Per-site takeover rules for the browser embedding |
| `DyNeo.test_strategy` | `'toggleterm'`, `'zellij'` inside zellij | How vim-test runs a test |
| `DyNeo.completion_sources` | `{}` | Completion sources named in the completion menu |

A plugin spec marked `dev = true` is looked for under `DyNeo.dev_plugins_path`
first; one missing from there is cloned from its git remote as usual, so the
folder need not exist.

### Plugin channels

| | `latest` (default) | `stable` |
| --- | --- | --- |
| Plugins | newest commit | newest release, or their branch when they tag none |
| Neovim | 0.13 nightly | 0.12 or newer |
| Lockfile | `lazy-lock.json` | `lazy-lock.stable.json` |

Each channel writes only its own lockfile, so a machine on `stable` and a
machine on `latest` never rewrite each other's pins.

### Updating plugins

An update is a week behind on purpose: the quarantine in
[lua/tools/lazy-quarantine.lua](./lua/tools/lazy-quarantine.lua) only lets
`:Lazy update` move to a commit, or a release, that has been out for seven
days — the same window the npm, bun, pnpm, uv and Mason sides use. `:Lazy
restore` and a pinned plugin are not touched by it. See
[A quarantine in front of Mason and lazy.nvim](#a-quarantine-in-front-of-mason-and-lazynvim).

The lockfile is the snapshot to roll back to, and both live in this
repository, so:

1. Commit the lockfile before `:Lazy update`, so the working pins are in git.
2. Update, then commit the new lockfile once everything still works.
3. If an update breaks something, put the previous lockfile back and check it
   out again:

   ```sh
   git restore lazy-lock.json # or: git checkout <commit> -- lazy-lock.json
   ```

   then run `:Lazy restore` in Neovim. A single plugin can be restored from
   its line in `:Lazy`.

## Languages, Frameworks, or Tools support

103 entries over 126 filetypes. The authoritative list is
[lua/config/languages.lua](./lua/config/languages.lua); what follows are its
keys, grouped.

### Languages

<details open>
<summary>42 languages</summary>

| | | | |
| --- | --- | --- | --- |
| Arduino | AWK | Bash¹ | C/C++ |
| C# | Clojure | CSS/Less | Cucumber |
| Dart | Elixir | Erlang | Fish |
| GDScript (Godot) | GDShader (Godot) | Gleam | Go |
| GraphQL | Haskell | HTML | Java |
| Javascript/Typescript | Julia | Kotlin | LaTeX |
| Lua | Nushell | OCaml | Perl |
| PHP | Python | R | Ruby |
| Rust | SASS/SCSS | Scala | Solidity |
| SQL | Swift | Typst | Vimscript |
| Zig | Zsh | | |

¹ including the build-recipe filetypes for Arch and Gentoo.

</details>

### Frameworks

<details open>
<summary>13 frameworks</summary>

| | | | |
| --- | --- | --- | --- |
| Angular | Astro | Django (templates) | Ember (Handlebars) |
| Laravel (Blade) | Phoenix (HEEx) | Qt (QML) | Rails |
| Rust | Svelte | Symfony (Twig) | Templ (Go) |
| Vue | | | |

</details>

### Tools & Markup

<details open>
<summary>38 tools and markup languages</summary>

| | | | |
| --- | --- | --- | --- |
| Ansible | Beancount | Bicep | CMake |
| CSV | CUE | D2 | DBML |
| Dockerfile | Git (rebase, commit) | GoTemplate (Helm…) | Groovy (Jenkinsfile) |
| HTTP Rest file | Hurl | Hyprlang | Jinja |
| jq | JSON | Jsonnet | Just |
| KDL (zellij) | Make (autoconf, automake) | Markdown | Mermaid |
| Nginx | Nix | Prisma | PromQL (Prometheus) |
| Protobuf | Rego | SystemD | Terraform |
| Terragrunt | TOML | Treesitter | XML |
| YAML | Yuck | | |

</details>

## Beyond the defaults

### Tooling that installs itself

One `FileType` autocmd, one table of handlers
([lua/util/lazy_install.lua](./lua/util/lazy_install.lua)). Opening a Go file
installs the Go parser, `gopls`, its linters, its formatters and `delve`;
nothing else in the table runs. An autocmd per tool would instead leave Neovim
a few hundred patterns to walk on every `FileType` event, and make the augroup
name the only thing keeping two handlers apart — a name two languages can
collide on, in which case one silently clears the other.

`DyNeo.bundle_languages` is the other end of the same dial: the languages listed
there are installed up front, which is what a container image or a prebuilt
development environment wants.

A tool Mason has no package for — one that comes from the system package
manager, from mise or from a script — can still be installed the same way. A
package of the repository's own registry with `source.id = 'dytoy:<tool>'`
hands the install to `dytoy --tool <tool>`, and each of its `bin` entries
becomes a link to the command wherever dytoy put it
([lua/tools/mason-dytoy.lua](./lua/tools/mason-dytoy.lua)). A tool already on
the machine is only linked, without dytoy. When the package manager needs
`sudo`, the password is asked for in Neovim, with `inputsecret()`, and handed
to sudo through `SUDO_ASKPASS`.

### A quarantine in front of Mason and lazy.nvim

Anything freshly published is held back for a week before it may be installed
— the same window `min-release-age` (npm), `minimumReleaseAge` (bun, pnpm) and
`exclude-newer` (uv) give the rest of these dotfiles, so a compromised release
has time to be caught and pulled before it lands on this machine. Both sides
read `DyNeo.quarantine_window`, so a machine can wait longer, or not at all.

Neither Mason nor lazy.nvim has a setting for it, and each needs a different
answer:

- **Mason** resolves no versions of its own — every package carries its
  version in the registry snapshot. So there is nothing to do per package:
  [lua/tools/mason-quarantine.lua](./lua/tools/mason-quarantine.lua) pins that
  snapshot to the newest registry release older than the window, instead of to
  the newest one.
- **lazy.nvim** decides what to check out in one function, for `:Lazy update`,
  for the hourly checker and for the update the UI offers alike.
  [lua/tools/lazy-quarantine.lua](./lua/tools/lazy-quarantine.lua) wraps it and
  hands back the newest commit, or the newest release, that has been out long
  enough. What lazy.nvim then does with that target is untouched, so `:Lazy
  restore` still puts the lockfile back commit for commit, and a pinned plugin
  stays where it is. A repository younger than the window is installed as
  lazy.nvim resolved it, since the alternative is not installing it at all.

A plugin is as much of a supply chain as a package from npm or PyPI, and a
bigger one: whatever is in it runs in this editor the next time Neovim starts.

Two edges the window alone leaves open are covered beside it. The bootstrap
clone of lazy.nvim itself is walked back to an aged commit by hand, since the
quarantine cannot hold back the clone that brings it in. And Mason runs its
npm and PyPI installs through [Socket
Firewall](https://socket.dev), which turns down a package known to be
malicious — the half of the problem a week of waiting cannot answer, because a
package can be caught after that week as easily as within it. `sfw` is a local
proxy, so the installer it wraps trusts the proxy's certificate instead of the
registry's: the verification moves to `sfw` rather than disappearing.

The window is otherwise invisible — `:Lazy` shows a plugin as up to date when
it is a week behind on purpose — so `:LazyQuarantine` lists what is being held
back: the commit or release each plugin is on, the one waiting for it, and how
long is left. It asks git once per plugin, about a second for the whole set.
`:checkhealth dyneo` answers the other half, whether the window is in place at
all.

### Files that never reach an AI

A language server is handed the whole text of every buffer it attaches to,
before a single suggestion is asked for. Opening a `.env` or a private key is
enough to upload it.

Every rule about secrets in this configuration is listed once, in
[lua/config/sensitive.lua](./lua/config/sensitive.lua) — dotenv and direnv
files, private keys, credential stores — and
[plugin/ai_guard.lua](./plugin/ai_guard.lua) guards every integration at the
one place it reads a buffer or a path: Copilot's `root_dir`, a chat handed a
file, a selection following the cursor into a CLI tool, a prompt on its way
out. A wrapper that no longer finds what it wraps leaves the plugin as it is
and says so, rather than breaking it on an upstream rename.

A name only goes so far, though: a scratch buffer, a YAML of deployment values
or a log pasted into a file carries credentials under a perfectly ordinary
name. So the text is searched as well, for the formats a credential is
recognisable by — a PEM header, `AKIA…`, `ghp_…`, a password in a URL — and a
match holds the whole buffer back. Each pattern recognises a token format and
nothing else: anything vaguer (`password = …`) would turn the guard off by
crying wolf. The buffer is read once per change, not once per question, since
the guards ask on every cursor move.

A buffer that stops being sensitive is offered back: delete the token again,
or waive the check, and Copilot is asked about the buffer once more — but only
when this guard is what took it away, never when the buffer was left without
it for a reason of its own.

Behind those patterns stands `betterleaks`, which already lints every buffer
here — from standard input, with `--redact` and its API validation off, so
nothing leaves the machine. The guard reads the diagnostics it leaves rather
than running it a second time: no extra process, and its whole rule set backs
the check. It only answers once it has run, on a write, a read or leaving
insert mode, which is what the built-in patterns are for — they answer the
instant a key is pressed, and they answer on a machine where `betterleaks` is
not installed yet.

| Command | What |
| ------- | ---- |
| `:AiGuardCheck` | Why this buffer is held back, and on which line |
| `:AiGuardAllow` | Waive the content check for this buffer, for as long as it is open |
| `:AiGuardAllow!` | Take that waiver back |

The same lists do a second job: `camouflage.nvim` masks a value on screen when
its key names a secret (`password`, `token`, `api_key`, …) or when the value
itself has the shape of one, so a format worth keeping from an AI is also one
worth keeping off the screen in a shared window. Every value of a file the
rules name sensitive stays masked whatever it is called; everywhere else a
Kubernetes manifest keeps reading like a Kubernetes manifest.

`:AiGuardAllow` is the way past a pattern that matched something that is not a
credential, and `:AiGuardAllow!` takes it back. It says nothing about the name
rules: a `.env` stays sensitive however often it is allowed. A waived buffer
says so in `:AiGuardCheck` and in `:checkhealth dyneo`, along with what it
would otherwise be held back for, so a waiver left on by mistake is visible
rather than silent.

### Schemas for YAML and JSON

YAML schemas are detected from the content of the buffer — Kubernetes
manifests, CRDs, cloud-init — and `<leader>cys` (or `:YamlSchema`) opens a
picker to set one for the buffer or write it in as a modeline. Candidates come
from the public catalogs, from the project, from `DyNeo.yaml_schema_dirs`, and
from any path typed in. `:YamlSchema reset` hands detection back the wheel.

### What is attached to this buffer

The statusline counts the language servers and the tools that are up rather
than spelling them out. The full list — every candidate, its state, and what
can be done about it — is one key or one click away:

| Key | What |
| --- | ---- |
| `<leader>cL` | Language servers of the buffer |
| `<leader>cT` | Formatters and linters of the buffer |

Each entry says whether the tool is installed, running, or missing, so a
formatter that quietly never fires stops being a mystery. Linters and
formatters only ever run when they are actually installed.

### Spelling, in several languages at once

`:DySpell {lang}` rebuilds a spell file with `mkspell` from the word lists
under `DyNeo.dictionaries_path` and `spell/`: Vietnamese, Chinese, plus the
`proper` and `technical` lists kept in this repository. Comments are
spell-checked as well as prose — through
[ltcc](https://github.com/dynamotn/languagetool-code-comments) — and the word
under the cursor, or a selection for anything with an apostrophe in it, can be
added to a list from a mapping.

### Diagrams in the terminal

D2 diagrams render inline on kitty-graphics terminals, `zellij` included.
`<leader>cp` previews the diagram under the cursor
([lua/tools/diagram/d2](./lua/tools/diagram/d2)); Markdown and Typst get their
own preview on the same key.

### Workspace diagnostics

`<leader>xw` asks a language server about the whole project, not only the
files that happen to be open, by handing it every file with
`textDocument/didOpen`. Unlike the plugin it replaces, the file list and the
contents are read off the main loop, so a big repository does not freeze the
editor, and each document is closed again before Neovim opens the same file
for real, so no server ever sees two `didOpen` for one URI.

### Tools given what they lack

Small gaps filled in [lua/tools](./lua/tools) and [lua/lint](./lua/lint), each
with a spec of its own:

- **jira** — issue completion in commit messages.
- **shellcheck** — code actions for the directives it suggests.
- **sonarlint** — connected mode, for both SonarQube and SonarCloud.
- **ltcc** — LanguageTool for code comments, as diagnostics and as code
  actions.
- **betterleaks**, **dyshellint**, **d2** — nvim-lint definitions that do not
  ship with the plugin.
- **terragrunt validate** — a diagnostic source of its own.
- **rule ids** — put back into the diagnostics nvim-lint leaves them out of,
  so `nvim-rulebook` can build an ignore comment for `markdownlint`,
  `ansible-lint`, `swiftlint` and friends.

### Integrations

- [Obsidian](https://obsidian.md/) — vaults from `DyNeo.obsidian.paths`.
- [chezmoi](https://www.chezmoi.io/) — templates edited with the target
  language injected, not as plain text.
- **Firefox** and **Chrome** — Neovim embedded in a textarea with
  [firenvim](https://github.com/glacambre/firenvim), tuned per site through
  `DyNeo.firenvim_site_settings`.
- [zellij](https://zellij.dev/) — test runner, terminal integration, and the
  pane sources for completion.
- [AI CLI tools](https://github.com/folke/sidekick.nvim#default-cli-tools) —
  through sidekick, behind the guard above.

## Key bindings

The leader key is `Space`. Press it and wait: which-key lists every mapping
under it, and `<Space>sk` searches all of them.

- Custom mappings live in [lua/config/keymaps.lua](./lua/config/keymaps.lua),
  and plugin-specific ones in the `keys` of each spec under
  [lua/plugins](./lua/plugins).
- The general defaults — windows, buffers, tabs, diagnostics, `<leader>u`
  toggles, git — sit at the top of the same file, ahead of the custom ones.

Every mapping, grouped the way which-key shows them, is in
[doc/neovim-config-keymaps.txt](./doc/neovim-config-keymaps.txt)
(`:help neovim-config-keymaps`), generated by `scripts/keymaps-doc.sh`. The
ones worth knowing before which-key gets a chance to tell you:

| Key | Mode | What |
| --- | ---- | ---- |
| `<leader>fy` | n | Copy the path of the file: relative or absolute, with line, with column, the directory, the project root, the file name |
| `<leader>cL`, `<leader>cT` | n | Language servers, formatters and linters of this buffer |
| `<leader>cys`, `<leader>cym` | n | Pick a YAML schema, or write it in as a modeline |
| `<leader>cp` | n | Preview the diagram, Markdown or Typst under the cursor |
| `<leader>xw` | n | Workspace diagnostics |
| `<leader>uk` | n | Camouflage: hide the values in a secret file |
| `<leader>ct` | n | Translate |
| `<leader>a` | n, x | AI CLIs through sidekick; Claude Code under `<leader>ac`, Avante under `<leader>av` |
| `<leader>yh`, `<leader>yi` | n, x | Yank history, paste an image |
| `<leader>pc` | n | Project LSP settings (codesettings) |
| `<leader>v` | n, x | Multiple cursors |
| `<C-c>` | n | Change word |
| `d`, `x`, `c`, `C`, `X` | n, v | Smart delete: a blank line goes to the black hole register |
| `/` | x | Search inside the selection |
| `<C-f>`, `<C-r>` | x | Search, replace the selected text |
| `:W`, `:Q`, `:Wq`, `:Qa`, … | c | The typo you meant |
| `:ww` | c | Save through `sudo tee` |

## Commands

| Command | What |
| ------- | ---- |
| `:DySpell {lang}` | Rebuild a spell file from its word lists |
| `:LazyQuarantine` | Plugins the release quarantine is holding back, and for how much longer |
| `:AiGuardCheck`, `:AiGuardAllow[!]` | Why this buffer is kept from the AI integrations, the way past the content check, and the way back |
| `:YamlSchema [modeline] [{path}]` | Pick the schema of this YAML buffer, or use the one at `{path}`; `modeline` writes it into the file instead |
| `:YamlSchema reset` | Hand schema detection back the wheel |
| `:DyNeoFormat`, `:DyNeoFormatInfo` | Format the buffer; which formatters would run, and whether it formats on save |
| `:DyNeoRoot` | The roots found for this buffer, the one in use first |

The plugins' own commands are unchanged.

## Help inside Neovim

The same ground, as a help file:

```vim
:help neovim-config
```

Tags are committed, so `:help` works in a fresh clone; after editing
[doc/neovim-config.txt](./doc/neovim-config.txt), regenerate them with
`:helptags doc`.

## Repository layout

| Path | What it holds |
| ---- | ------------- |
| `init.lua` | Globals, per-machine overrides, the version gate, lazy.nvim |
| `lua/config/` | `globals`, `languages`, `options`, `keymaps`, `autocmds`, `defaults`, `sensitive` |
| `lua/plugins/` | Plugin specs by area: `coding`, `executor`, `integration`, `lang`, `lsp`, `toolbox`, `treesitter`, `ui` |
| `lua/util/` | Shared helpers the specs call into |
| `lua/tools/` | Features built here: the Mason and lazy.nvim quarantines, Mason registry entries, diagram rendering, workspace diagnostics, extra completion sources and code actions |
| `lua/lint/linters/` | nvim-lint definitions the plugin does not ship |
| `lua/overseer/` | Task templates |
| `lua/per_machine/` | The per-machine overrides, rendered by chezmoi |
| `lsp/`, `ftplugin/`, `after/`, `queries/` | Native Neovim configuration, filetype by filetype |
| `plugin/` | `ai_guard`, `spell` |
| `snippets/`, `spell/`, `colors/`, `ftdetect/` | The rest of the runtime path |
| `scripts/` | Benchmarks, checks, the test runner |
| `tests/` | plenary-busted specs |
| `doc/` | The help file, and the mapping reference generated from the config |

## Development

### Tests

47 spec files under `tests/spec` run with
[plenary-busted](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness)
in a headless Neovim that loads only the module each spec requires:

```sh
scripts/test.sh                                  # every spec
scripts/test.sh tests/spec/util                  # one directory
scripts/test.sh tests/spec/util/sensitive_spec.lua
```

Plenary and lazy.nvim are taken from lazy.nvim's install directory, or cloned
into `.tests/` when the configuration has never been started.

### Checks

```sh
scripts/test.sh                                       # unit tests
scripts/check-startup.sh                              # load everything, open a file of each language
nvim --clean --headless -l scripts/validate-tools.lua  # every tool name, against conform, nvim-lint, lspconfig and Mason
scripts/keymaps-doc.sh                                # rewrite doc/neovim-config-keymaps.txt from the mappings set
pre-commit run --all-files                            # the lot, plus stylua
```

What those cannot see is the machine the configuration is running on, so
`:checkhealth dyneo` ([lua/dyneo/health.lua](./lua/dyneo/health.lua)) asks it:
whether this Neovim is new enough for the plugin channel, what nvim-treesitter
still needs to build parsers, whether the quarantine in front of Mason and lazy.nvim is the one actually
running and how old the registry snapshot it settled on is, whether the
windows bun and uv read still agree with it, which guard of `util.ai_guard`
found nothing to wrap and what the current buffer would be held back for,
which tools that never come from Mason are missing here, and whether the
programs the quick start asks for are installed.

All of it runs as pre-commit hooks and in CI
([.github/workflows/check.yml](./.github/workflows/check.yml)), on both plugin
channels.

## Benchmark

Two of them, because they measure different halves of the same editor:

```bash
nvim --clean --headless -l scripts/bench.lua            # starting Neovim
nvim --clean --headless -l scripts/bench-filetypes.lua  # opening a file
```

Starting Neovim only reaches `init.lua`. The `FileType` dispatcher, the
language servers, the linters and formatters, and every plugin that loads on a
buffer event are left alone until a file is opened, so the second benchmark
opens one file of every filetype in this configuration, each in a Neovim of its
own. Neither installs anything.

Both rewrite their own section below when a number moves by more than a
threshold; `BENCH_FORCE=1` and `BENCH_FT_FORCE=1` rewrite it regardless, and
`BENCH_FT_ONLY=lua,go` times just those filetypes without touching this file.

Take the filetype milliseconds for what they are. Every run is a whole Neovim
process, and on a laptop that is noisy in a way averaging does not remove: two
sweeps of the same tree, nothing changed between them, put individual
filetypes anywhere from 0.6x to 2.7x of each other. So a single row is an
order of magnitude, the `plugins` column next to it is the figure that does
not move, and the summary over all the filetypes is what the section is
rewritten on. Measure a change by running the benchmark twice, before and
after, the same way round — a sweep against a sweep, or `BENCH_FT_ONLY`
against `BENCH_FT_ONLY`, never one against the other and never against the
table below.

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
