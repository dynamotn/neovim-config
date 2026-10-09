---
description: Review the staged changes before they are committed
---
Review these staged changes before they are committed, as a careful senior
engineer would.

List real problems first -- bugs, missed edge cases, security and
performance risks, leftovers such as debug output or commented-out code --
each with its file and line and a concrete fix. Then, briefly, whatever
could be simpler, and anything that belongs in a separate commit. Say so
plainly when there is nothing worth changing.

Staged files:

{files}

The staged diff:

{fence}diff
{diff}
{fence}
