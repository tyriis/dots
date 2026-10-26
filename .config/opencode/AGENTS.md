# Global agent rules

## "jarvis" means the Hermes agent with profile jarvis

Whenever the user says "jarvis", they mean the Hermes agent instance on this
computer running with the `jarvis` profile (`~/.hermes/profiles/jarvis`).

How to reach it:
- CLI wrapper: `~/.local/bin/jarvis` — a thin wrapper around
  `/usr/bin/hermes -p jarvis`.
- A persistent instance runs as the systemd user service
  `jarvis-serve.service` (Hermes serve gateway on `0.0.0.0:9119`).
- For programmatic one-shot calls (scripts, pipes, agent tooling), use
  Hermes' one-shot mode `-z`, which prints only the final response text to
  stdout, with tools/memory/rules loaded and approvals auto-bypassed.

Exact example of calling it:

```sh
jarvis -z "Summarize today's calendar"
# equivalent to: hermes -p jarvis -z "Summarize today's calendar"
```

## Temporary files: use /tmp/<project>, never bare /tmp

External-directory writes prompt by default (global `external_directory: ask`).
To keep that surface narrow and grantable:

- Put scratch, socket, and tool-runtime files under a project-scoped dir named
  after the repo — `/tmp/<project>/…` (e.g. `/tmp/ledgerdemo/`), created with
  `mkdir -p /tmp/<project>` — never loose in `/tmp` or other external paths.
- Where a tool honours an env var for its temp dir (e.g. `TMPDIR`), point it at
  the project dir instead of letting it default to a bare `/tmp` location.
- Prefer already-allowed prefixes when they fit: `~/projects/*`, `~/research/*`,
  `/tmp/opencode/*`.
- Permission additions in `opencode.jsonc` follow the same rule: allow a
  specific `/tmp/<project>/*` (ideally in the repo's own
  `.opencode/opencode.jsonc`), never `/tmp/*` or broader.

## Pull requests in tyriis and git.techtales.io repos

Applies when a pull request is requested in a repo whose origin matches
`github.com/tyriis/*` or `git.techtales.io/*`.

Use the create-pr skill for all PR work in these repos.

Hard constraints (always in force, even outside these hosts):
- Never merge a PR and never squash. Merging stays a manual or
  repo-specific step (home-ops: `task git:pr-merge -- <N>`).
- Never run `gh` locally — no auth on this machine.
- Never open a PR the user did not ask for.
- Always end by posting the PR URL as a link in chat.
