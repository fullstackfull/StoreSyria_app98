# Golden baselines — reviewed by a human, then committed. Never by the agent that wrote the test.

**This directory is empty of images on purpose.** The eight PNG files you may see beside this README
in a working tree are **generated output**, not committed baselines.

Route 1 of the Flutter rendering-evidence blocker
(`docs/PHASE-2.5-FLUTTER-RENDERING-EVIDENCE-BLOCKER-AR.md` §3) is three steps, and only the first is
automated:

1. **Capture.** The `goldens (capture for human review)` job in `.github/workflows/ci.yml` —
   `workflow_dispatch` only — runs `flutter test --tags golden --update-goldens` and uploads the
   PNGs as an artifact.
2. **Review.** A person downloads that artifact and **looks at every image**, in both themes and
   both directions, then commits the ones that are correct **into this directory**.
3. **Compare.** From then on the ordinary blocking `flutter test` compares pixels on every push,
   because each golden case stops skipping the moment its own baseline file exists
   (`test/support/golden_harness.dart::goldenReady`).

**Why step 2 cannot be skipped.** A baseline generated and committed by the same automation that
wrote the test records whatever the code drew — a defect included — and then asserts it for ever.
The first capture in this repository is the proof: it came back with the customer card's three
info-row icons drawn as **empty squares**, because `flutter test` does not load MaterialIcons unless
something asks it to. Committing that capture unreviewed would have frozen a missing glyph into all
eight images. It was found by *looking*, not by the capture exiting 0.

**Do not commit an image you have not looked at.**

`test/golden/golden_infrastructure_test.dart` guards this directory: it fails if a surface is only
**partly** captured (three correct pictures out of four read as coverage and are not — the direction
defect these goldens exist to catch lived in exactly one of the four combinations), and it prints
how many of the expected baselines are present on every run, so an empty directory is visible in the
test output rather than hidden behind skip lines.

Expected set, four combinations each (light/dark × LTR/RTL):

| surface | files |
|---|---|
| `customer-card` | `customer-card.light-ltr.png`, `.light-rtl.png`, `.dark-ltr.png`, `.dark-rtl.png` |
| `delivery-boy-card` | `delivery-boy-card.light-ltr.png`, `.light-rtl.png`, `.dark-ltr.png`, `.dark-rtl.png` |
