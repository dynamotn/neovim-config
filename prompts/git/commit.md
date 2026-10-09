---
description: Write the commit message of the staged changes
---
Write the git commit message for the staged changes below.

- Answer with the message only: no preamble, no code fence.
- A subject line of about 50 characters, in the imperative mood, saying what
  a user of the code gains or sees, not which files changed.
- {convention}
- A body only when the reason for the change is not obvious from the diff:
  a blank line after the subject, then a few lines wrapped at 72 columns
  saying why. Do not restate the diff.
- No trailers, no emoji, no mention of AI.

Recent subjects of this repository, to match their style:

{history}

Staged files:

{files}

The staged diff:

```diff
{diff}
```
