---
description: Explain why a CI job failed and how to fix it
---
The CI job `{job}` failed. Say why, from its log below: the first error
that matters, not the noise that follows it. Then say how to fix it --
in the code, in `{file}`, or in the environment -- with the change to make.
Say plainly when the log does not show the cause, and what to look at next.

The run: {run}

The pipeline file, `{file}`:

{fence}yaml
{workflow}
{fence}

The end of the job's log:

{fence}text
{log}
{fence}
