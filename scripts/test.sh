#!/usr/bin/env bash
# @file test.sh
# @brief Run the unit tests under tests/spec
# @description
#   Runs the specs with plenary-busted in a headless Neovim that loads nothing
#   of this configuration but the modules each spec requires.
#
#     scripts/test.sh                       # every spec
#     scripts/test.sh tests/spec/util       # one directory
#     scripts/test.sh tests/spec/util/sensitive_spec.lua
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
init="${repo}/tests/minimal_init.lua"
target="${1:-${repo}/tests/spec}"

if ! command -v nvim > /dev/null 2>&1; then
  echo "test: nvim not found" >&2
  exit 1
fi

cd "${repo}"
if [[ -f "${target}" ]]; then
  # Run in this very Neovim, which has loaded minimal_init.lua already;
  # `PlenaryBustedFile` would start a child without it.
  command="lua require('plenary.busted').run('${target}')"
else
  options="{minimal_init = '${init}', sequential = true, timeout = 60000}"
  command="PlenaryBustedDirectory ${target} ${options}"
fi
exec nvim --headless --noplugin -i NONE -u "${init}" -c "${command}" < /dev/null
