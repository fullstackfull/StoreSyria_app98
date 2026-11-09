# The golden baselines show a card stretched to 800px, and the app never renders one

> ## RESOLVED 2026-11-09 — and the proposed fix below was only HALF the cause
>
> Flutter 3.47.7 (the version `.github/workflows/ci.yml` pins) is installed in the execution
> container now, so the change this document asked the next round to make could be applied,
> regenerated and **measured**. It was, and the measurement refuted it.
>
> **`Align` alone changed nothing.** With `Scaffold(body: Align(alignment: AlignmentDirectional
> .topStart, child: child))` the recaptured images were still 98.3% `Colors.white` in light and
> 98.2% `cCardBackground` in dark, with the last differing row still at `y = 799`. Identical to the
> numbers in this document.
>
> **The rest of it is in the widgets, not the harness.** Both cards are a `Container` with a width
> and no height wrapping a `Column` with no `mainAxisSize` — and a `Column` defaults to
> `MainAxisSize.max`, i.e. "be as tall as the incoming maxHeight". Loosening the constraints was
> necessary and not sufficient: given a loose 800px box the Column still chose 800.
>
> MEASURED directly, by `test/ui/card_intrinsic_height_test.dart` before the repair:
>
> | card | in a scrolling list (what the app draws) | in a bounded 800px box |
> |---|---:|---:|
> | customer | **141.0px** | **800.0px** |
> | delivery man | **120.0px** | **800.0px** |
>
> **Why the app looked right, and why that was not a reason to leave it.** Both cards render inside
> a scrolling list (`customer_screen.dart:282-287`), where the main axis is UNBOUNDED, so
> `MainAxisSize.max` has nothing to expand into. The cards were content-height *by accident of
> their surroundings*; in any bounded box — a sheet, a grid cell, a golden harness — they stretched.
>
> **Both halves are now applied**: `Align(AlignmentDirectional.topStart)` in `goldenHost()` and
> `mainAxisSize: MainAxisSize.min` on both cards' root `Column`. After them,
> `customer-card.dark-ltr.png` reads **82.2% `cBackGround`** (the page, previously absent from the
> top four colours) and **15.8% `cCardBackground`** (the card), with the last differing row at
> **`y = 142`** instead of 799.
>
> ### And the repair uncovered a defect this document had retracted
>
> §"A correction to a reading I made first" withdrew the claim that the card's fill is identical to
> the page's. That retraction was **right about dark and wrong about light**:
> `LightThemeColor.cBackGround` is `0xffFFFFFF` (`colors.dart:72`) and the light card's fill is
> `Colors.white` — **the same colour**, separated only by a shadow at alpha .035, measured at
> **1.08:1**. It could not be seen while the card covered the whole page. The light card now carries
> a 1px `LightThemeColor.cBorder` edge (1.43:1 on white); dark keeps its fill difference
> (#18263F on #0F1A2E, 1.15:1) and gets no outline, because an outline there would fight a surface
> that is already reading.
>
> **The eight regenerated images are still CANDIDATES.** `test/golden/goldens/*.png` is gitignored
> by owner instruction and nothing has been committed into that directory. Route 1 step 2 — a human
> looking at every image in both themes and both directions — is unchanged.

---

**Original status, kept as written: a measured finding with a proposed fix. NOTHING HAD BEEN
CHANGED at the time.** The fix invalidates all eight committed baselines, and regenerating them
needs the manual `goldens (capture for human review)` job plus a human review — route 1 step 2.
Making the change without that would turn the blocking `flutter test` red on eight golden
mismatches.

## What was measured

The eight baselines in `test/golden/goldens/` were read as images and their pixels counted.

| baseline | dominant colour | share | what that colour is |
|---|---|---|---|
| `customer-card.dark-ltr.png` | `rgb(24, 38, 63)` | **98.2%** | `DarkThemeColor.cCardBackground` — **the card's own fill** |
| `customer-card.light-ltr.png` | `rgb(255, 255, 255)` | **98.3%** | `Colors.white` — **the card's own fill** |

And the scaffold's background is **essentially absent**:

* dark: `DarkThemeColor.cBackGround` = `rgb(15, 26, 46)` is present but not in the top four colours.
* light: `LightThemeColor.cBackGround` = `rgb(220, 228, 241)` is **not present at all**.

A row-by-row scan for a horizontal edge below the text block found exactly one non-background row
in the whole 800px image — `y = 799`, the rounded-corner artefact at the very bottom.

**So the card fills the entire 360×800 surface.** It is not a card at the top of a page; it is a
card stretched down the page.

### A correction to a reading I made first

Looking at the images, I first concluded that *the card's fill is identical to the page's*, so the
card had no surface distinction. **That was wrong.** `cCardBackground` (`0xFF18263F`) and
`cBackGround` (`0xFF0F1A2E`) are different tokens with a real difference. The page simply is not
visible, because the card covers it. The defect is the framing, not the palette.

## Why it matters

1. **A human reviewing these baselines is approving a picture the app never draws.** The real
   screen wraps the card in `Padding(bottom: 12.h)` inside a list
   (`customer_screen.dart:282-287`), so it is content-height with siblings above and below.
2. **A height regression would be invisible.** If the card's intrinsic height changed, or the
   constraint around it broke, the stretched baseline would look the same — the comparison cannot
   see a difference in a dimension the harness has pinned to the viewport.
3. **98% of every comparison is one flat colour**, so the pixel diff is dominated by a region that
   carries no information, while the 2% that does is a thin band at the top.

## The cause

`customer_card_golden_test.dart:117` matches the golden against the **Scaffold**:

```dart
await expectLater(
  find.byType(Scaffold),
  matchesGoldenFile(goldenPath('customer-card', combination)),
);
```

and `goldenHost()` is `Scaffold(body: child)` (`golden_harness.dart:207-210`), which gives its body
tight constraints — so a card with no height of its own expands to fill them.

Capturing the Scaffold is a deliberate and good choice: it is what puts the real theme background
in the picture. The missing piece is that the body must not be told to fill it.

## The proposed fix

One line in `goldenHost`, so every surface gets it rather than each test remembering:

```dart
home: Directionality(
  textDirection: direction,
  child: Scaffold(
    body: Align(alignment: AlignmentDirectional.topStart, child: child),
  ),
),
```

`AlignmentDirectional`, not `Alignment`, so the RTL baselines keep their own leading edge.

After it:

* the card renders at its content height,
* the scaffold background becomes visible and therefore *tested*,
* a height regression becomes a visible diff,
* and the comparison's pixels are mostly the widget under review.

**Then all eight baselines must be regenerated and reviewed again**, because every one of them
changes. That is route 1 step 2 and it is a human's step by design: a baseline generated and
committed by the same author records whatever the code did, defects included, and then asserts it
for ever (`golden_harness.dart:258-260`).

## Not done at the time, and why — now done

`flutter` was not installed in that container, so the baselines could not be regenerated or the
change verified. Editing the harness then would have left eight mismatching baselines and a red
blocking `flutter test`. The change was written out above so the next round — in an environment
with Flutter, or through the manual capture job — could apply it, regenerate, and put the pictures
in front of the owner.

**That round is 2026-11-09.** The SDK was installed at the pinned 3.47.7, the fix was applied,
and it was found to be half of the cause — see the box at the top of this file. `flutter analyze`
reports 0 errors and 0 warnings; `flutter test` is 1544 passing. The eight images are regenerated
and remain uncommitted candidates.

**What this says about the finding, and it is worth saying.** Everything this document MEASURED was
correct — the percentages, the absent background, the single differing row at `y = 799`, the three
consequences. What it got wrong was the CAUSE, and it got that wrong by reading one plausible
mechanism (`Scaffold`'s tight constraints) and stopping. The mechanism was real; it was not
sufficient. A one-line fix that cannot be executed cannot be refuted, which is the argument for
installing the toolchain rather than reasoning around its absence.
