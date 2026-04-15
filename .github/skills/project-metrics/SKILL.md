---
name: project-metrics
description: 'Collect deterministic project health metrics for the weather app. Use when: assessing the project, identifying coverage gaps, checking test-to-source ratios, auditing dependencies, reporting lint status. Runs shell commands to get real data instead of guessing.'
argument-hint: 'Optional focus area: tests | deps | lint | all (default: all)'
user-invocable: true
---

# Project Metrics

## When to Use

Load this skill when you need factual, up-to-date project data:
- Counting tests, source files, or lines of code per layer
- Identifying source files with no matching test file
- Checking current dependencies and their versions
- Getting a lint status summary

**Always run the script — never guess at counts or dependency versions.**

## Procedure

1. Run [collect-metrics.ps1](./scripts/collect-metrics.ps1) with PowerShell:
   ```
   pwsh -NoProfile -File .github/skills/project-metrics/scripts/collect-metrics.ps1
   ```
   Or on Unix/macOS:
   ```
   pwsh -NoProfile -File .github/skills/project-metrics/scripts/collect-metrics.ps1
   ```

2. The script outputs a JSON object. Parse each section:
   - `source_files` — count and list of `.py` files per layer under `src/`
   - `test_files` — count and list per `tests/unit/` and `tests/integration/`
   - `coverage_gaps` — source modules with no corresponding test file
   - `dependencies` — installed package names and versions from `uv pip list`
   - `lint_status` — exit code and violation count from `ruff check`

3. Summarize findings in a structured table. Flag:
   - Any source layer where `test_count == 0`
   - Any `coverage_gaps` entries
   - Lint violations > 0

4. Include the raw JSON in a collapsed `<details>` block so it's available for reference without cluttering the summary.

## Output Format

Present results in this order:
1. **Quick summary** (3–5 bullet points, key numbers only)
2. **Layer breakdown table** (source files vs test files per layer)
3. **Coverage gaps** (source files with no test counterpart)
4. **Dependency list** (package: version)
5. **Lint status** (pass / N violations)
