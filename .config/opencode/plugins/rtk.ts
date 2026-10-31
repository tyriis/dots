import { Plugin } from "@opencode/plugin"
import { execFileSync } from "node:child_process"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH. V2 format (Plugin.define + ctx.tool.hook).
//
// Thin delegating plugin: all rewrite logic lives in `rtk rewrite`
// (src/discover/registry.rs upstream).
//
// NOTE: `rtk init -g --opencode` writes the V1 format to this path and will
// overwrite this file — re-port after any rtk-init run.

function rtkRewrite(command: string): string {
  try {
    return execFileSync("rtk", ["rewrite", command], {
      encoding: "utf8",
      timeout: 2000,
    }).trim()
  } catch (e: any) {
    // rtk rewrite exits non-zero (3) on success paths too; stdout still holds
    // the rewritten command when it did — mine it from the error object.
    return typeof e?.stdout === "string" ? e.stdout.trim() : ""
  }
}

export default Plugin.define({
  id: "rtk",
  async setup(ctx: any) {
    try {
      execFileSync("which", ["rtk"], { encoding: "utf8" })
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", (event: any) => {
      const tool = String(event?.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const input = event?.input
      if (!input || typeof input !== "object") return

      const command = (input as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      const rewritten = rtkRewrite(command)
      if (rewritten && rewritten !== command) {
        ;(input as Record<string, unknown>).command = rewritten
      }
    })
  },
})
