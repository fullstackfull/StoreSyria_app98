# The golden baselines show a card stretched to 800px, and the app never renders one

**Status: a measured finding with a proposed fix. NOTHING HAS BEEN CHANGED.** The fix invalidates
all eight committed baselines, and regenerating them needs the manual
`goldens (capture for human review)` job plus a human review — route 1 step 2. Making the change
without that would turn the blocking `flutter test` red on eight golden mismatches.

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

## Not done here, and why

`flutter` is not installed in this container, so the baselines cannot be regenerated or the change
verified. Editing the harness now would leave eight mismatching baselines and a red blocking
`flutter test`. The change is written out above so the next round — in an environment with Flutter,
or through the manual capture job — can apply it, regenerate, and put the pictures in front of the
owner.
