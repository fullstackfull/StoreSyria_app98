# Phase 2.5 — account handoff (Flutter side)

**Written:** 2026-11-09. The full handoff lives in the Laravel repository, because the phase spans
both and the coverage matrix is generated there:

> `fullstackfull/syriastore98` →
> `docs/development/phase-2.5/PHASE-2.5-ACCOUNT-HANDOFF.md`
> on branch `claude/gracious-volta-duiynj` at **`77da951b`**

> **WE ARE IN PHASE 2.5, NOT PHASE 02.** Phase 02 is closed. Phase 2.5 — *Premium Merchant
> Experience & Visual Excellence* — is an approved extra station **between Phase 02 and Phase 03**.
> Do not re-open or re-execute Phase 02.

---

## This repository, at a glance

| | |
|---|---|
| branch | `claude/gracious-volta-duiynj` |
| HEAD (pushed) | `4382202` |
| unpushed commits | 0 |
| worktree | clean |
| pull request | [#8](https://github.com/fullstackfull/StoreSyria_app98/pull/8) — **draft**, base `claude/busy-edison-k0pjwa`. **Keep it draft.** |
| parent PR to `main` | [#7](https://github.com/fullstackfull/StoreSyria_app98/pull/7) — open |

### CI at `4382202`

| | |
|---|---|
| ✅ | Analyze and test |
| ✅ | Secrets and suppression hygiene |
| ⊘ | `goldens (capture for human review)` — **skipped by design**, `workflow_dispatch` only |

---

## The Flutter gap is the largest in the phase

The coverage matrix counts **75 Flutter surfaces across two areas, with ZERO done**:

| area | total | PENDING | BLOCKED | done |
|---|---:|---:|---:|---:|
| Flutter merchant admin app | 51 | 51 | 0 | **0** |
| Flutter merchant/employee admin app | 24 | 21 | 3 | **0** |

**The previous container had no `flutter` installed**, so none of this could be executed there —
only analysed. **Check whether your environment has `flutter` before planning around it.** If it
does, this area is where the phase gains the most.

---

## What exists here already

* **Golden-test infrastructure (route 1)** — `test/support/golden_harness.dart`,
  `test/golden/golden_infrastructure_test.dart`, `test/golden/customer_card_golden_test.dart`.
* **Eight committed baselines** — `customer-card` and `delivery-boy-card`, each in four
  combinations (light/dark × ltr/rtl), under `test/golden/goldens/`.
* **Capture is deliberately manual.** The `goldens` job is `workflow_dispatch` only, and
  `golden_infrastructure_test.dart` asserts that it stays that way. The reason is written at
  `golden_harness.dart:258-260`: *a baseline generated and committed by the same author records
  whatever the code did, including a defect, and then asserts it for ever.* A human reviews the
  pictures once and commits them. **Do not automate that step.**
* An uncaptured case **skips with a reason that says what to do**, so the blocking `flutter test`
  stays green without excluding a tag from it.

## One open finding, measured and deliberately not applied

`docs/design/GOLDEN-BASELINE-FRAMING.md` records that **the eight baselines show a card stretched
to 800px, which the app never renders**:

```
customer-card.dark-ltr.png    98.2% is rgb(24,38,63)    = DarkThemeColor.cCardBackground
customer-card.light-ltr.png   98.3% is rgb(255,255,255) = Colors.white
```

Both are **the card's own fill**; the scaffold background is essentially absent. `Scaffold(body:
child)` gives its body tight constraints, so a card with no height of its own expands. The real
screen wraps it in `Padding(bottom: 12.h)` inside a list (`customer_screen.dart:282-287`).

The fix is one line in `goldenHost` — `body: Align(alignment: AlignmentDirectional.topStart, child:
child)` — and it is **NOT applied**, because it invalidates all eight baselines and the previous
container could not regenerate or verify them. Applying it means: change the harness, run the
manual capture job, have a human review the new pictures, commit them. In that order.

---

## Standing constraints

* **No merge to `main`. No force push. No history rewrite.** PR #8 stays **draft**.
* **Preserve the API contract with the Laravel backend.** One live example: `User::dateFormat()` on
  the server feeds `plan_expire_date` and `trial_expire_date`, which `my_plan_widget.dart:128`
  **displays verbatim and never parses**. The server was deliberately left unlocalised there for
  that reason — public API compatibility is the owner's call, not an agent's.
* **Return 403, not 401**, for an authenticated user lacking permission: this app forces a logout
  on any 401.
* **Never commit secrets or real customer data.**
* **No PREMIUM VERIFIED promotion without the owner's visual acceptance.**
