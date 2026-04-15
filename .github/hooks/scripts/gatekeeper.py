#!/usr/bin/env python3
"""Smart Gatekeeper — PreToolUse hook.

Reads the tool invocation from stdin (JSON), checks the command string
against allow and deny lists, and writes a permissionDecision to stdout.

Decision table:
  ALLOW  — safe, read-only or test commands; no prompt needed.
  ASK    — destructive or network-reaching; human must approve.
  (none) — everything else passes through to VS Code's default flow.
"""

import json
import re
import sys

# ── patterns ────────────────────────────────────────────────────────────────

# Commands that are safe to auto-approve.
ALLOW_PATTERNS: list[str] = [
    r"\bpytest\b",
    r"\buv\s+run\s+pytest\b",
    r"\buv\s+run\s+ruff\b",
    r"\buv\s+sync\b",
    r"\bls\b",
    r"\bdir\b",
    r"\bcat\b",
    r"\btype\b",           # Windows equivalent of cat
    r"\bhead\b",
    r"\btail\b",
    r"\bgrep\b",
    r"\bSelect-String\b",  # PowerShell grep
    r"\bfind\b",
    r"\bGet-ChildItem\b",
    r"\bwc\b",
    r"\bGet-Content\b",
    r"\becho\b",
    r"\bpwd\b",
    r"\bGet-Location\b",
]

# Commands that must be confirmed by a human before running.
ASK_PATTERNS: list[str] = [
    r"\brm\b",
    r"\bRemove-Item\b",
    r"\bdel\b",
    r"\brmdir\b",
    r"pip\s+install\b",
    r"\bcurl\b",
    r"\bwget\b",
    r"git\s+push\b",
    r"git\s+reset\b",
    r"git\s+clean\b",
    r"git\s+force\b",
    r"\bgit\b.*--force\b",
    r"\bgit\b.*-f\b",
    r"sudo\b",
    r"chmod\b",
    r"chown\b",
    r"Format-Volume\b",
    r"Clear-RecycleBin\b",
]

# Only gate terminal-execution tools; let file-edit and search tools pass.
TERMINAL_TOOL_NAMES = {
    "run_in_terminal",
    "run_terminal_command",
    "execute_command",
    "terminal",
    "bash",
    "shell",
}

# ── helpers ──────────────────────────────────────────────────────────────────


def _decide(command: str) -> str | None:
    """Return 'allow', 'ask', or None (pass-through) for the given command."""
    for pattern in ALLOW_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return "allow"
    for pattern in ASK_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return "ask"
    return None


def _output(decision: str, reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": decision,
                    "permissionDecisionReason": reason,
                }
            }
        ),
        flush=True,
    )


# ── main ─────────────────────────────────────────────────────────────────────


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)  # Malformed input — pass through safely

    # Only inspect terminal tool calls.
    tool_name: str = data.get("tool_name", "").lower()
    if tool_name not in TERMINAL_TOOL_NAMES:
        sys.exit(0)

    # Extract the command string; field name varies across tool versions.
    tool_input: dict = data.get("tool_input", data.get("tool_parameters", {}))
    command: str = tool_input.get("command", "").strip()
    if not command:
        sys.exit(0)

    decision = _decide(command)
    if decision == "allow":
        _output("allow", "Safe read-only or test command — auto-approved")
    elif decision == "ask":
        snippet = command[:100]
        _output(
            "ask",
            f"Destructive or network-reaching command requires human approval: '{snippet}'",
        )
    # else: pass through — no output, exit 0


if __name__ == "__main__":
    main()
