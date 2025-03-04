# neovim-config

<!--toc:start-->
<!--markdownlint-disable MD013-->
- [neovim-config](#neovim-config)
  - [Feature](#feature)
  - [Languages, Frameworks, or Tools support](#languages-frameworks-or-tools-support)
    - [Languages](#languages)
    - [Frameworks](#frameworks)
    - [Tools & Markup](#tools--markup)
  - [Installation](#installation)
  - [Key bindings](#key-bindings)
  - [Benchmark](#benchmark)
<!--toc:end-->

My customization configuration for neovim

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.10-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Feature

- 🔥 Transform your Neovim into a full-fledged IDE
- 🚀 Blazingly fast and furious (see [benchmark](#benchmark))
- 🧹 Sane default settings for options, autocmds, and keymaps
- 📦 Comes with a wealth of plugins pre-configured and ready to use **for DevOps and SA**, like me
  - Supported many languages, frameworks and tools (see [here](#languages-frameworks-or-tools-support))
  - Load per machine configurations via `lua/per_machine.lua` if exists (see [my config](./lua/per_machine.lua.tmpl), managed by [chezmoi](https://www.chezmoi.io/))
  - Lazy install treesitter parsers, LSP servers, formatters, linters, debug adapters... if needed when open file
  - Bundle languages/tools when containerize or builtin development environments by `_G.bundle_languages` in [init.lua](./init.lua) (see [my config](./lua/per_machine.lua.tmpl))
  - Enable/disable languages/tools by `_G.enabled_languages` in [init.lua](./init.lua) (see [my config](./lua/per_machine.lua.tmpl))
  - Easy to show which tools are installed in lualine
  - Trigger linters/formatters if installed only
  - Integrate with various tools:
    - [Obsidian](https://obsidian.md/) by `_G.obsidian_vaults` in [init.lua](./init.lua) (see [my config](./lua/per_machine.lua.tmpl))
    - [chezmoi](https://www.chezmoi.io/)
    - **Firefox** or **Chrome** browser with [embedded neovim](https://github.com/glacambre/firenvim)
    - [zellij](https://zellij.dev/)
    - [Codeium](https://codeium.com/), an AI power tools

> [!CAUTION]
>
> - Not used for neovim < 0.10 or vim (any version)
> - Used for Linux only or Mac (not sure)

## Languages, Frameworks, or Tools support

See the list of supported things in [lua/config/languages.lua](./lua/config/languages.lua)

### Languages

- Arduino
- AWK
- Bash (include some filetypes for build package on Arch, Gentoo)
- C/C++
- C#
- CSS/Less
- Cucumber
- Fish
- Go
- HTML
- Javascript/Typescript
- Java
- LaTeX
- Lua (of course)
- PHP
- Python
- Ruby
- Rust
- SASS/SCSS
- Solidity
- SQL

### Frameworks

- Angular
- Vue
- Rust

### Tools & Markup

- Ansible
- Beancount
- Bicep
- CMake
- CSV
- D2
- DBML
- Dockerfile
- Git (rebase, commit)
- GoTemplate (Helm template...)
- Groovy (also for Jenkinsfile)
- HTTP Rest file
- Hyprlang
- JSON
- Make tools (autoconf, automake, make)
- Markdown
- Nginx
- Nix
- OpenAPI
- Terraform
- Terragrunt
- TOML
- Treesitter
- YAML
- Yuck

## Installation

- Clone this repository to ~/.config/nvim.

```sh
  rm -rf ~/.config/nvim
  git clone https://gitlab.com/dynamo-config/vim ~/.config/nvim --single-branch --depth 1
```

- After that, open Neovim. That's all! Hope you enjoy with neovim :smile:!

## Key bindings

My habit key is `Space`. You can explore it :)

## Benchmark

- Startup time (benchmark by [vim-startuptime](https://github.com/dstein64/vim-startuptime)):

```
       startup: 43.7
event                  time percent plot
init.lua              32.30   73.98 ██████████████████████████
config.lazy           31.68   72.56 █████████████████████████▌
UIEnter autocommands   3.86    8.84 ███▏
dial.augend            2.22    5.08 █▊
config.options         1.75    4.00 █▍
reading ShaDa          1.55    3.54 █▎
config.filetype        1.38    3.17 █▏
catppuccin.vim         1.28    2.94 █
vim.filetype           1.07    2.44 ▉
neogen.utilities.nod   1.04    2.38 ▉

```

- By [hyprfine](https://github.com/sharkdp/hyperfine) on my laptop machine:

```sh
> hyperfine "nvim +q" "nvim +q --headless" "nvim README.md +q --headless" "nvim lua/config/lazy.lua +q"
Benchmark 1: nvim +q
  Time (mean ± σ):      45.0 ms ±   4.4 ms    [User: 31.3 ms, System: 12.1 ms]
  Range (min … max):    40.3 ms …  60.4 ms    49 runs
 
Benchmark 2: nvim +q --headless
  Time (mean ± σ):      72.5 ms ±  41.4 ms    [User: 49.1 ms, System: 20.6 ms]
  Range (min … max):    38.6 ms … 140.0 ms    68 runs
 
Benchmark 3: nvim README.md +q --headless
  Time (mean ± σ):      83.0 ms ±  46.1 ms    [User: 58.7 ms, System: 21.4 ms]
  Range (min … max):    42.3 ms … 152.8 ms    21 runs
 
Benchmark 4: nvim lua/config/lazy.lua +q
  Time (mean ± σ):     328.6 ms ±  14.8 ms    [User: 331.3 ms, System: 160.7 ms]
  Range (min … max):   298.3 ms … 353.1 ms    10 runs
 
Summary
  nvim +q ran
    1.61 ± 0.93 times faster than nvim +q --headless
    1.84 ± 1.04 times faster than nvim README.md +q --headless
    7.30 ± 0.78 times faster than nvim lua/config/lazy.lua +q

```
