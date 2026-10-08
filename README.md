<div align="center">

# DyNeo

**Neovim, turned into a DevOps & SA workstation.**

One table per language · nothing installed until a file asks · a supply chain on a leash

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.13-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![Built on lazy.nvim](https://img.shields.io/badge/built%20on-lazy.nvim-blueviolet.svg?style=flat-square)](https://lazy.folke.io)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)

<sub><i>DyNeo</i> reads as <i>đi nào</i>, Vietnamese for "let's go" — and as <b>Dy</b>namo + <b>Neo</b>vim.</sub>

</div>

## ✨ Highlights

| | |
| --- | --- |
| 🧩 **One entry per language** | Parser, servers, linters, formatters, debugger and test runner in one table of [`languages.lua`](./lua/config/languages.lua) |
| 🪶 **Nothing eager** | A language's tooling installs the first time one of its files opens; startup stays in the tens of milliseconds |
| 🔒 **Supply chain on a leash** | Updates wait a week, can be reviewed before they land, and what is installed exports as an SBOM checked against OSV |
| 🤖 **AI with a guard rail** | Secrets never reach Copilot, Avante, sidekick or Claude Code, and every handover is logged |
| 🎛 **One tree, many machines** | Laptop, workstation or container: the same checkout, a few globals apart |
| 🛟 **Two channels** | `latest` rides plugin `main` on Neovim nightly; `stable` takes releases. Each keeps its own lockfile |

## 🚀 Quick start

```sh
git clone https://gitlab.com/dynamo-config/neovim.git ~/.config/nvim --single-branch --depth 1
# or beside your own config:  … ~/.config/dynamo && NVIM_APPNAME=dynamo nvim
```

Needs **Neovim 0.13+** (0.12+ on `stable`), **git**, a [Nerd Font](https://www.nerdfonts.com/),
**curl**/**tar**/**unzip**/**gzip**, a **C compiler** with the
[tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli),
**ripgrep** and **fd**. Everything else installs itself; `:checkhealth dyneo`
says what is missing.

> [!CAUTION]
> Neovim only, on Linux and macOS. `latest` can break with any `:Lazy update` —
> set `DyNeo.plugin_channel = 'stable'` where it must not.

## 🧰 What you get

| | What | Try |
| --- | --- | --- |
| 🔒 | **Quarantine** — Mason and plugin releases wait a week; review what an update adds, flagged; SBOM and OSV check | `:LazyQuarantine review` · `:DySbom osv` |
| 🤖 | **AI guard** — `.env`, keys and token-shaped text kept from every AI; masked on screen; every handover logged | `:AiGuardCheck` · `:AiGuardLog` |
| 🏗 | **Infrastructure** — YAML schemas detected (Kubernetes, CRDs, cloud-init); Kubernetes diff, server dry run, apply, Helm and Kustomize render; `tofu plan` shown on the blocks it changes; Markdown runbooks run in place, destructive steps asking first | `<localleader>k` · `<localleader>p` · `<localleader>r` · `<leader>cys` |
| 🌐 | **Forges & trackers** — GitHub (Octo), GitLab merge requests, CI checks, Jira issues to branches and worklogs | `<leader>ph` `pl` `pc` `pj` |
| 🔍 | **Whole-project diagnostics** — every file handed to the server, off the main loop | `<leader>xw` |
| 🛠 | **Tasks** — run, build and test the current file or project in ~50 languages | `<leader>oo` |
| 🖼 | **Previews** — D2 diagrams inline on kitty-graphics terminals, Markdown, Typst | `<leader>cp` |
| 📚 | **Spelling** — Vietnamese, Chinese and technical word lists; code comments too | `:DySpell vi` |
| 🔌 | **Integrations** — Obsidian, chezmoi templates, firenvim, zellij, AI CLIs | |

<details>
<summary><b>42 languages · 13 frameworks · 38 tools</b> — 126 filetypes in all</summary>

**Languages** — Arduino, AWK, Bash, C/C++, C#, Clojure, CSS/Less, Cucumber,
Dart, Elixir, Erlang, Fish, GDScript, GDShader, Gleam, Go, GraphQL, Haskell,
HTML, Java, JS/TS, Julia, Kotlin, LaTeX, Lua, Nushell, OCaml, Perl, PHP,
Python, R, Ruby, Rust, SASS/SCSS, Scala, Solidity, SQL, Swift, Typst,
Vimscript, Zig, Zsh

**Frameworks** — Angular, Astro, Django, Ember, Laravel, Phoenix, Qt (QML),
Rails, Rust, Svelte, Symfony, Templ, Vue

**Tools & markup** — Ansible, Beancount, Bicep, CMake, CSV, CUE, D2, DBML,
Dockerfile, Git, GoTemplate/Helm, Groovy, HTTP, Hurl, Hyprlang, Jinja, jq,
JSON, Jsonnet, Just, KDL, Make, Markdown, Mermaid, Nginx, Nix, Prisma, PromQL,
Protobuf, Rego, SystemD, Terraform, Terragrunt, TOML, Treesitter, XML, YAML,
Yuck

</details>

## 📖 Help

Configuration, mappings and commands live inside Neovim:

```vim
:help dyneo                " everything
:help dyneo-configuration  " per-machine settings and every DyNeo.* global
:help dyneo-keymaps        " every mapping
:help dyneo-commands       " every command
```

…or press `<Space>` and let which-key show the way.

## 🧪 Development

<details>
<summary>Checks, layout</summary>

```sh
scripts/test.sh [path]       # plenary-busted specs
scripts/check-startup.sh     # load everything, open a file of each language
scripts/keymaps-doc.sh       # regenerate doc/dyneo-keymaps.txt
pre-commit run --all-files   # all of the above, and more
```

`lua/config/` holds the globals, languages and options; `lua/plugins/` the
plugin specs; `lua/tools/` the features built here; `doc/` the help.

</details>

## Benchmark

<details>
<summary>Startup and per-filetype timings</summary>

`nvim --clean --headless -l scripts/bench.lua` (startup) and
`scripts/bench-filetypes.lua` (opening a file) rewrite the tables below when a
number really moves. Single rows are noisy: compare before and after, not
against these.

<!-- bench:start -->
<!-- Generated by scripts/bench.lua; edit that, not this. -->

Measured with `nvim --startuptime` over 10 runs on AMD Ryzen 9 5950X 16-Core Processor (Linux x86_64), Neovim 0.13.0, 2026-10-09.

| Command | Median | Mean ± σ | Min | Max | Wall clock |
| ------- | -----: | -------: | --: | --: | ---------: |
| `nvim --headless +q` | 45.7 ms | 46.5 ± 2.3 ms | 44.9 ms | 52.6 ms | 49.9 ms |
| `nvim --headless README.md +q` | 257.7 ms | 256.9 ± 2.9 ms | 252.9 ms | 261.3 ms | 335.4 ms |
| `nvim --headless init.lua +q` | 150.8 ms | 150.7 ± 2.3 ms | 147.3 ms | 154.2 ms | 212.1 ms |

Slowest steps of `nvim --headless +q` (self + sourced, mean):

```
step                            time percent  plot
init.lua                       43.10   92.61  ████████████████████████▏
config.lazy                    42.06   90.38  ███████████████████████▌
catppuccin.vim                  2.41    5.17  █▍
catppuccin                      1.74    3.74  █
vim.filetype                    1.60    3.44  ▉
lazy.core.handler.event         1.24    2.66  ▊
filetype.lua                    1.03    2.21  ▋
vim._core.defaults              0.92    1.98  ▌
config.globals                  0.89    1.91  ▌
lazy.core.loader                0.89    1.90  ▌
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

</details>
