---
name: create-backlog-item
description: 'Create a structured backlog item for this weather app. Use when: writing a backlog item, creating a task spec, producing acceptance criteria, planning a feature, sizing work for an agent. Always load the canonical template from this skill instead of inventing a format.'
argument-hint: 'Feature or task to turn into a backlog item, e.g. "add UV index to weather response"'
---

# Create Backlog Item

## When to Use

Load this skill whenever you are asked to:
- Create, write, or produce a backlog item
- Plan a feature and break it into tasks
- Write acceptance criteria or a definition of done
- Size work for an implementing agent

## Procedure

1. **Load the template.** Read [backlog-item-template.md](./backlog-item-template.md) — use it verbatim as the structure for every item you produce. Do not invent sections or skip any.

2. **Fill in each section:**
   - **Title** — concise imperative phrase (≤10 words).
   - **Description** — one paragraph: what it delivers and why it matters.
   - **Acceptance Criteria** — 3–5 observable, testable bullets. No vague "works correctly" statements.
   - **TDD Requirements** — name the exact test files (`tests/unit/test_<module>.py`, `tests/integration/test_<module>_api.py`). Reference `tests/factories.py` for test data.
   - **Files to Create or Modify** — list every file path with a brief note on the change.
   - **Sizing** — S / M / L with rationale. Never produce an L item — split it first.
   - **Definition of Done** — always include the standard checklist.

3. **Validate sizing:**
   - S = ≤2 files, 1 architectural layer
   - M = 3–4 files, ≤2 layers
   - L = split required — break into two or more M/S items before proceeding

4. **Stop for review.** Present the draft to the human before writing it to a file. Ask: "Does this look right? Any acceptance criteria missing?"

5. **On approval**, write the item to `docs/backlog/<slug>.md` where `<slug>` is a lowercase hyphenated version of the title.

## Quality Rules

- Acceptance criteria must be independently verifiable — each one should be checkable without running the whole suite.
- TDD Requirements must name specific file paths, not just say "write tests".
- The `Files to Create or Modify` list must be exhaustive — if the implementing agent touches a file not listed here, the backlog item was under-specified.
- Sizing must be honest. When in doubt, split.
