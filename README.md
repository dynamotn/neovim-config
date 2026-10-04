# neovim-config

> My customization configuration for neovim

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.13-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

<!-- toc -->

- [Features](#features)
- [Languages, Frameworks, or Tools support](#languages-frameworks-or-tools-support)
  - [Languages](#languages)
  - [Frameworks](#frameworks)
  - [Tools & Markup](#tools--markup)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Install](#install)
  - [Per machine settings](#per-machine-settings)
  - [Updating plugins](#updating-plugins)
- [Testing](#testing)
- [Key bindings](#key-bindings)
- [Benchmark](#benchmark)

<!-- tocstop -->

## Features

- 🔥 Transform your Neovim into a full-fledged IDE
- 🚀 Blazingly fast and furious (see [benchmark](#benchmark))
- 🧹 Sane default settings for options, autocmds, and keymaps
- 📦 Comes with a wealth of plugins pre-configured and ready to use **for DevOps and SA**, like me
  - Supported many languages, frameworks and tools (see [here](#languages-frameworks-or-tools-support))
  - Load per machine configurations via `lua/per_machine/init.lua` if exists (see [my config](./lua/per_machine/config.lua.tmpl), managed by [chezmoi](https://www.chezmoi.io/))
  - Lazy install treesitter parsers, LSP servers, formatters, linters, debug adapters... if needed when open file
  - Bundle languages/tools when containerize or builtin development environments by `_G.bundle_languages` in [lua/config/globals.lua](./lua/config/globals.lua) (see [my config](./lua/per_machine/config.lua.tmpl))
  - Enable/disable languages/tools by `_G.enabled_languages` in [lua/config/globals.lua](./lua/config/globals.lua) (see [my config](./lua/per_machine/config.lua.tmpl))
  - Choose how far ahead plugins run by `_G.plugin_channel` in [lua/config/globals.lua](./lua/config/globals.lua), per machine:
    - `latest` (default): LazyVim `main` and every plugin at its newest commit, on a Neovim nightly
    - `stable`: LazyVim and every plugin that tags releases on its newest release, on Neovim 0.12 or newer. Plugins without releases, or whose last one is years old, stay on their branch
  - Easy to show which tools are installed in lualine
  - Trigger linters/formatters if installed only
  - Add bunch of missing features of the different tools:
    - `jira`
    - `shellcheck`
    - `sonarlint` (with connected mode for both SonarQube and SonarCloud)
    - YAML schemas detected from content (Kubernetes, CRDs, cloud-init), and a picker (`<leader>cy`, `:YamlSchema`) to set one per buffer or insert it as a modeline, from the catalogs or from local files (the project, `_G.yaml_schema_dirs`, or any path)
    - Spell check for comments
    - Render diagram on kitty terminal (also support `zellij`)
    - etc
  - Integrate with various tools:
    - [Obsidian](https://obsidian.md/) by `_G.obsidian.paths` in [lua/config/globals.lua](./lua/config/globals.lua) (see [my config](./lua/per_machine/config.lua.tmpl))
    - [chezmoi](https://www.chezmoi.io/)
    - **Firefox** or **Chrome** browser with [embedded neovim](https://github.com/glacambre/firenvim)
    - [zellij](https://zellij.dev/)
    - [Various AI CLI tool](https://github.com/folke/sidekick.nvim#default-cli-tools)

> [!CAUTION]
>
> - Not used for vim (any version), or for neovim < 0.13 on the default `latest` channel (< 0.12 on `stable`)
> - The default `latest` channel follows the newest neovim (currently 0.13 nightly) and plugin commits, so an upstream break can land with any `:Lazy update`. Set `_G.plugin_channel = 'stable'` on a machine that should not ride along
> - Used on Linux and macOS

## Languages, Frameworks, or Tools support

See the list of supported things in [lua/config/languages.lua](./lua/config/languages.lua)

### Languages

- Arduino
- AWK
- Bash (include some filetypes for build package on Arch, Gentoo)
- C/C++
- C#
- Clojure
- CSS/Less
- Cucumber
- Dart
- Elixir
- Erlang
- Fish
- GDScript (Godot)
- GDShader (Godot)
- Gleam
- Go
- GraphQL
- Haskell
- HTML
- Javascript/Typescript
- Java
- Julia
- Kotlin
- LaTeX
- Lua (of course)
- Nushell
- OCaml
- Perl
- PHP
- Python
- R
- Ruby
- Rust
- SASS/SCSS
- Scala
- Solidity
- SQL
- Swift
- Typst
- Vimscript
- Zig
- Zsh

### Frameworks

- Angular
- Astro
- Django (templates)
- Ember (Handlebars)
- Laravel (Blade)
- Phoenix (HEEx)
- Qt (QML)
- Rails
- Rust
- Svelte
- Symfony (Twig)
- Templ (Go)
- Vue

### Tools & Markup

- Ansible
- Beancount
- Bicep
- CMake
- CSV
- CUE
- D2
- DBML
- Dockerfile
- Git (rebase, commit)
- GoTemplate (Helm template...)
- Groovy (also for Jenkinsfile)
- HTTP Rest file
- Hurl
- Hyprlang
- Jinja
- jq
- JSON
- Jsonnet
- Just
- KDL (zellij)
- Make tools (autoconf, automake, make)
- Markdown
- Mermaid
- Nginx
- Nix
- Prisma
- PromQL (Prometheus)
- Protobuf
- Rego
- SystemD
- Terraform
- Terragrunt
- TOML
- Treesitter
- XML
- YAML
- Yuck

## Installation

### Requirements

- **Neovim 0.13+** (nightly). Older versions stop at an error message.
- **git**, to bootstrap [lazy.nvim](https://github.com/folke/lazy.nvim) and
  clone the plugins on the first start.
- A [Nerd Font](https://www.nerdfonts.com/) in the terminal, for the icons.
- **curl**, **tar**, **unzip** and **gzip**, which Mason uses to download
  tools.
- A **C compiler** and the
  [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli),
  which `nvim-treesitter` needs to build parsers.
- **ripgrep** and **fd**, for the pickers and the ripgrep completion source.

Everything else is installed lazily: the first time a file of a language is
opened, its Treesitter parser, LSP servers, linters, formatters and debug
adapters are installed by Mason. Many of those packages are built by a
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

- Back up and clone this repository to `~/.config/nvim`:

```sh
  mv ~/.config/nvim ~/.config/nvim.bak
  git clone https://gitlab.com/dynamo-config/vim ~/.config/nvim --single-branch --depth 1
```

- Open Neovim. The plugins are cloned on the first start, the language tools
  when their files are first opened.

### Per machine settings

[chezmoi](https://www.chezmoi.io/) is not needed. It renders
[lua/per_machine/config.lua.tmpl](./lua/per_machine/config.lua.tmpl) into
`lua/per_machine/config.lua` on my machines; in a plain clone that file does
not exist and the defaults in [lua/config/globals.lua](./lua/config/globals.lua)
are used. To change them, write `lua/per_machine/config.lua` by hand and
assign the globals there, e.g.:

```lua
_G.dark_mode = false
_G.enabled_languages = { 'lua', 'bash', 'markdown' }
_G.obsidian.paths.personal = vim.fn.expand('~/Notes')
_G.dictionaries_path = vim.fn.expand('~/.local/share/dictionaries')
```

Locally developed plugins (specs with `dev = true`) are looked for under
`_G.dev_plugins_path`, which the `NVIM_DEV_PLUGINS` environment variable
overrides. A plugin missing from there is cloned from its git remote instead.

### Updating plugins

The lockfile is the snapshot to roll back to: `lazy-lock.json` on `latest`,
`lazy-lock.stable.json` on `stable`. Both live in this repository, so:

1. Commit the lockfile before `:Lazy update`, so the working pins are in git.
2. Update, then commit the new lockfile once everything still works.
3. If an update breaks something, put the previous lockfile back and check it out again:

   ```sh
   git restore lazy-lock.json # or: git checkout <commit> -- lazy-lock.json
   ```

   then run `:Lazy restore` in Neovim. A single plugin can be restored from its line in `:Lazy`.

## Testing

Unit tests live in `tests/spec` and run with
[plenary-busted](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness)
in a headless Neovim that loads only the module each spec requires:

```sh
scripts/test.sh                                  # every spec
scripts/test.sh tests/spec/util                  # one directory
scripts/test.sh tests/spec/util/sensitive_spec.lua
```

Plenary and LazyVim are taken from lazy.nvim's install directory, or cloned
into `.tests/` when the configuration has never been started. The same run is
a pre-commit hook and a CI step, next to `scripts/check-startup.sh`, which
loads the whole configuration and opens a file of each language.

## Key bindings

The leader key is `Space`. Press it and wait: [which-key](https://github.com/folke/which-key.nvim)
lists every mapping under it, and `<Space>sk` searches all of them.

- Custom mappings live in [lua/config/keymaps.lua](./lua/config/keymaps.lua),
  and plugin-specific ones in the `keys` of each spec under [lua/plugins](./lua/plugins).
- Everything else follows [LazyVim's defaults](https://www.lazyvim.org/keymaps).

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

Measured with `nvim --startuptime` over 10 runs on AMD Ryzen 9 5950X 16-Core Processor (Linux x86_64), Neovim 0.13.0, 2026-10-03.

| Command | Median | Mean ± σ | Min | Max | Wall clock |
| ------- | -----: | -------: | --: | --: | ---------: |
| `nvim --headless +q` | 37.8 ms | 38.0 ± 1.8 ms | 36.2 ms | 42.4 ms | 41.4 ms |
| `nvim --headless README.md +q` | 316.8 ms | 317.4 ± 5.4 ms | 309.1 ms | 326.1 ms | 429.0 ms |
| `nvim --headless init.lua +q` | 142.6 ms | 141.9 ± 4.1 ms | 136.9 ms | 151.1 ms | 213.3 ms |

Slowest steps of `nvim --headless +q` (self + sourced, mean):

```
step                            time percent  plot
init.lua                       35.12   92.32  ████████████████████████
config.lazy                    34.25   90.02  ███████████████████████▍
catppuccin.vim                  2.27    5.98  █▌
catppuccin                      1.51    3.96  █
vim.filetype                    0.95    2.51  ▋
filetype.lua                    0.89    2.34  ▋
vim._core.defaults              0.77    2.02  ▌
config.globals                  0.77    2.01  ▌
helpview.nvim/helpview.lua      0.75    1.98  ▌
helpview                        0.64    1.69  ▌
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
