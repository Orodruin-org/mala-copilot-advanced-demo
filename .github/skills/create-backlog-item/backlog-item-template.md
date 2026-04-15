# Backlog Item Template

Use this exact structure for every backlog item. Do not add, rename, or remove sections.

---

# <Title — concise imperative phrase, ≤10 words>

## Description

One paragraph explaining what this item delivers and why it matters to the weather app.

## Acceptance Criteria

- [ ] Criterion 1 — observable, independently testable (e.g., "GET /weather?city=London returns `uv_index` field as a float")
- [ ] Criterion 2
- [ ] Criterion 3

## TDD Requirements

- Write failing tests in `tests/unit/test_<module>.py` **before** any production code.
- If a new endpoint is added, also write `tests/integration/test_<module>_api.py`.
- Use `tests/factories.py` for all test data. Add new factory functions there if needed.
- All tests must be passing (`uv run pytest`) before the item is considered done.

## Files to Create or Modify

List every file the implementing agent will touch. Be exhaustive — unlisted files are out of scope.

- `src/weather_app/<layer>/<file>.py` — describe the change
- `tests/<scope>/test_<module>.py` — new or updated tests

## Sizing

**S / M / L** — choose one and give the rationale.

| Size | Rule |
|------|------|
| S    | ≤2 files, 1 architectural layer |
| M    | 3–4 files, ≤2 architectural layers |
| L    | Split required — never produce an L item; decompose first |

Sizing: **?** — _rationale_

## Definition of Done

- [ ] All acceptance criteria met
- [ ] All tests pass: `uv run pytest`
- [ ] No lint errors: `uv run ruff check src/ tests/`
- [ ] No files modified outside the listed paths
- [ ] PR reviewed and approved (if applicable)
