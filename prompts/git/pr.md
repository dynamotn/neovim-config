---
description: Write the title and description of a pull request
---
Write the pull request for the branch `{branch}`, going into `{base}`.

- Answer with Markdown only: the title as a `# ` heading on the first line,
  then the description. No preamble, no code fence around the answer.
- {convention}
- The description says what changes for a user of the code and why, then
  how it was done where that is not obvious, then how it was tested. Use
  short sections and lists; leave out a section with nothing to say.
- Point out anything a reviewer should look at closely, and any follow-up
  left out of this change.
- Do not restate the diff file by file. No mention of AI.

The commits:

{commits}

Changed files:

{files}

The diff:

{fence}diff
{diff}
{fence}
