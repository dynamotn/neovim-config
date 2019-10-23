`<Leader>` key is `\`.

My configuration use `<SPC>` as bonus mnemonic prefix. In this documentation, it's represent by `SPC` key.

You must use `:help index` to see all default key bindings of each mode.

Note: Mode abbrev in below tables:
- N is Normal
- I is Insert
- V is Visual
- C is Command
- E is Ex

### Fn key
| Key binding | Mode | Description |
|-------------|------|-------------|
|F1|N|Same as `Esc`|
|F3|N I|Toggle paste mode|
|F4|N|Show terminal in vim, use `Esc Esc` to return vim from editing or running command|

### Ctrl key
| Key binding | Mode | Description |
|-------------|------|-------------|
|Ctrl+I|N|Reload vim configuration and install plugins|
|Ctrl+S|N I|Save file (same with other editor)|
|Ctrl+J|N|Switch to below window|
|Ctrl+K|N|Switch to above window|
|Ctrl+H|N|Switch to left window|
|Ctrl+L|N|Switch to right window|
|Ctrl+R|V|Replace selected text|
|Ctrl+SPC|I|LSP autocomplete with coc|

### Leader key
`n` is number key

| Key binding | Mode | Description |
|-------------|------|-------------|
|\ `n`|N|Switch to tab with index `n`|
|\ -|N|Switch to previous tab|
|\ +|N|Switch to next tab|
|||
|\ w|N|Write file and exit|
|||
|\ t n|N|Open new tab|
|\ t o|N|Close other tabs|
|\ t c|N|Close tab|
|\ t h|N|Switch to previous tab|
|\ t l|N|Switch to next tab|
|\ t e|N|Open new tab with file in current folder|
|\ f n|N|Insert name of file in cursor position|
|\ f p|N|Insert path of file in cursor position|

### Space key
| Key binding | Mode | Description |
|-------------|------|-------------|
|SPC f e|N|Open file explorer|
|||
|SPC g c|N|Move to next git conflict|
|||
|SPC l m|N|Preview Markdown file on browser|
|||
|SPC w s|N|Switch to other buffer|
|SPC w 2|N|Create windows layout with 2 columns|
|SPC w 3|N|Create windows layout with 3 columns|
|SPC w =|N|Resize all windows to balance|

### Square bracket key
`n` is number key, if doesn't have, it's equivalent with 1

| Key binding | Mode | Description |
|-------------|------|-------------|
|`n` [ SPC|N|Add `n` empty lines before|
|`n` ] SPC|N|Add `n` empty lines after|
|`n` [ e|N|Move current line before `n` lines|
|`n` ] e|N|Move current line after `n` lines|

### Other key
| Key binding | Mode | Description |
|-------------|------|-------------|
|<|N V|Shift the highlighted lines or current line to left|
|>|N V|Shift the highlighted lines or current line to right|
|, SPC|N|Remove all trailing spaces|

### Command mode
| Key binding | Description |
|-------------|-------------|
|:w!!|Write file with root permission|
|W|Same with w|
|W!|Same with w!|
|Wq|Same with wq|
|wQ|Same with wq|
|WQ|Same with wq|
|Wa|Same with wa|
|Q|Same with q|
|Q!|Same with q!|
|Qa!|Same with qa!|
|Qa|Same with qa|
