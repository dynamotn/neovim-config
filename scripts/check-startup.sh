#!/usr/bin/env bash
# Load this configuration in a throwaway Neovim, open a file of each common
# filetype in it (see check-startup.lua), and fail on any error.
#
# The repository has no test suite, so a syntax error or a bad `require` is
# only found by opening the editor -- and in a chezmoi `mode: symlink` setup
# that is the real editor, already broken. Neovim is pointed at this tree
# rather than at `$HOME`, so the check reads what is about to be committed and
# not what was applied last time.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v nvim > /dev/null 2>&1; then
  echo "check-startup: nvim not found, skipping" >&2
  exit 0
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
mkdir -p "$workdir/config"
ln -s "$repo" "$workdir/config/nvim"

output="$workdir/output.txt"
set +e
XDG_CONFIG_HOME="$workdir/config" nvim --headless -i NONE \
  -c "luafile ${repo}/scripts/check-startup.lua" > "$output" 2>&1
status=$?
set -e

# Neovim reports a broken configuration on stderr and still exits 0, so the
# output has to be looked at as well as the exit code.
if [[ ${status} -ne 0 ]] || grep -qE '^(E[0-9]+:|Error)' "$output"; then
  echo "check-startup: the configuration failed to load" >&2
  cat "$output" >&2
  exit 1
fi
