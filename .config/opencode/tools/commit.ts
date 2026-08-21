import { execFile } from "node:child_process"
import { promisify } from "node:util"
import { mkdtempSync, writeFileSync, rmSync } from "node:fs"
import os from "node:os"
import path from "node:path"
import { tool } from "@opencode-ai/plugin"

const execFileAsync = promisify(execFile)
const VALIDATOR_RULE_RE = /^RULE=(one-line|whitespace|length|regex)$/
const SCOPE_REQUIRED_ERROR =
  "scope is required unless skip_scope is explicitly set by the user"

type Result =
  | { ok: true; hash: string; message: string }
  | { ok: false; rule: string | null; error: string; stderr?: string }

const json = (result: Result) => JSON.stringify(result)

// Plan §6.3 step 3: spawn the validator with the composed message on stdin.
// Deviation: Node v26.5.0's promisified execFile hangs when the child reads
// stdin and `input` is supplied. We therefore hand the validator a temporary
// file path as $1 (file-mode is exactly what the validator supports; see
// guardrail/validate-commit-msg.sh §2). The temp file is unlinked in
// `finally` so no secrets linger if a future message were to carry them.
async function runValidator(
  validator: string,
  message: string,
): Promise<{ ok: true } | { ok: false; stderr: string }> {
  const dir = mkdtempSync(path.join(os.tmpdir(), "git-commit-msg-"))
  const msgPath = path.join(dir, "commit-msg.txt")
  writeFileSync(msgPath, message)
  try {
    await execFileAsync("bash", [validator, msgPath], { encoding: "utf8" })
    return { ok: true }
  } catch (error) {
    const stderr = String((error as { stderr?: string }).stderr ?? "")
    return { ok: false, stderr }
  } finally {
    try {
      rmSync(dir, { recursive: true, force: true })
    } catch {}
  }
}

export default tool({
  description:
    "Compose, validate, and create one deterministic git commit. Never bypasses hooks.",
  args: {
    change_type: tool.schema
      .enum(["feat", "fix", "docs", "style", "refactor", "test", "ci", "chore", "revert"])
      .describe(
        "Commit type; the breaking `!` is controlled separately by `breaking`.",
      ),
    breaking: tool.schema
      .boolean()
      .default(false)
      .describe(
        "Set true only when the change is breaking; inserts `!` after the scope.",
      ),
    scope: tool.schema
      .string()
      .regex(/^$|^[a-z0-9-]+$/)
      .max(32)
      .default("")
      .describe(
        "Lowercase kebab-case scope; required unless skip_scope is true. Empty string is allowed so the gate below can enforce the rule.",
      ),
    skip_scope: tool.schema
      .boolean()
      .default(false)
      .describe(
        "Set true ONLY when the user explicitly approved skipping scope; never set on agent initiative.",
      ),
    short_description: tool.schema
      .string()
      .regex(/^\S.*\S$|^\S$/)
      .max(60)
      .describe(
        "Imperative one-line summary without leading or trailing whitespace.",
      ),
    ticket: tool.schema
      .string()
      .regex(/^#[0-9]+$|^[A-Z]+-[0-9]+$/)
      .optional()
      .describe("Optional GitHub #123 or Jira KEY-456 ticket."),
  },
  async execute(args, context) {
    // §6.3 step 1: scope gate fires before composition.
    if (!args.skip_scope && !args.scope) {
      return json({ ok: false, rule: "scope-required", error: SCOPE_REQUIRED_ERROR })
    }

    // §6.3 step 2: deterministic composition; `!` is placed by code, never by the model.
    const tail = args.breaking ? "!" : ""
    const message = args.scope
      ? `${args.change_type}(${args.scope})${tail}: ${args.short_description}${args.ticket ? " " + args.ticket : ""}`
      : `${args.change_type}${tail}: ${args.short_description}${args.ticket ? " " + args.ticket : ""}`

    // §6.3 validator path resolution.
    const validator =
      process.env.GIT_COMMIT_VALIDATOR ??
      path.join(os.homedir(), ".config", "git-commit", "validate-commit-msg.sh")

    // §6.3 step 3-4: validator → structured error with RULE= prefix.
    const v = await runValidator(validator, message)
    if (!v.ok) {
      const firstLine = v.stderr.split(/\r?\n/, 1)[0] ?? ""
      const match = firstLine.match(VALIDATOR_RULE_RE)
      const rule = match ? match[1] : null
      const errorLines = match
        ? v.stderr.split(/\r?\n/).slice(1).join("\n").trim()
        : ""
      return json({
        ok: false,
        rule,
        error: errorLines || "validator did not emit RULE= prefix",
        stderr: v.stderr,
      })
    }

    // §6.3 step 5: `git commit -m` via execFile, NO --no-verify (the hook must run).
    // Dotfiles fallback: $HOME is the worktree of a bare repo at ~/.dotfiles, so
    // `rev-parse --show-toplevel` fails there; resolve the repo explicitly.
    let root: string
    let gitArgs: string[] = []
    try {
      const { stdout: rootOutput } = await execFileAsync(
        "git",
        ["rev-parse", "--show-toplevel"],
        { cwd: context.worktree, encoding: "utf8" },
      )
      root = rootOutput.trim()
    } catch (error) {
      if (context.worktree !== os.homedir()) throw error
      const dotfilesDir = path.join(os.homedir(), ".dotfiles")
      try {
        await execFileAsync(
          "git",
          ["--git-dir", dotfilesDir, "rev-parse", "--git-dir"],
          { cwd: os.homedir(), encoding: "utf8" },
        )
      } catch {
        throw error
      }
      root = os.homedir()
      gitArgs = ["--git-dir", dotfilesDir, "--work-tree", os.homedir()]
    }
    await execFileAsync("git", [...gitArgs, "commit", "-m", message], {
      cwd: root,
      encoding: "utf8",
    })
    const { stdout: hashOutput } = await execFileAsync(
      "git",
      [...gitArgs, "rev-parse", "HEAD"],
      { cwd: root, encoding: "utf8" },
    )
    return json({ ok: true, message, hash: hashOutput.trim() })
  },
})
