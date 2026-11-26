#!/usr/bin/env python3
"""Build the route-1 CONTACT SHEET from a directory of captured golden images.

WHY THIS FILE EXISTS, AND IT IS NOT CONVENIENCE
===============================================
`docs/evidence/route-1-candidates/CONTACT-SHEET.png` is what a reviewer actually looks at, and
until now it had no generator anywhere in this repository: it was made once, by hand, beside the
eight wave-1 candidates in d7d38d5 (2026-11-07). Three commits later 3727efc (2026-11-09) fixed the
card framing, the eight PNGs and the sheet were never re-made, and the review package went on
showing a defect that the code no longer had -- measured at 82.5% and 85.2% of differing pixels in
the two dark card surfaces. A review package that cannot be regenerated in one command is a review
package that goes stale, so the command is now in the repository next to the images.

WHAT IT DOES NOT DO. It does not approve anything, it does not write into `test/golden/goldens/`,
and it does not decide which images are correct. It lays captured PNGs out side by side with their
combination named under each one so that a person can look at all of them at once. Route 1 step 2 --
a human eye on every image -- is unchanged and is not performed by this script.

THE CROP IS COMPUTED, NOT CONFIGURED. Every capture is the full 360x800 harness surface and the
surfaces are content-height since 3727efc, so a fixed crop would either cut a tall card off or leave
most of a sheet empty. Each row is cropped to the tallest content in that row plus `--page-margin`
rows of page background, which is deliberate: the band of page colour UNDER the card is the visible
proof that the card is content-height rather than filling its box, which is exactly the regression
this directory shipped once already.

USAGE
    python3 tool/contact_sheet.py \
        --images-dir docs/evidence/route-1-candidates \
        --out docs/evidence/route-1-candidates/CONTACT-SHEET.png \
        --note "Flutter 3.47.7 - flutter test --tags golden --update-goldens" \
        --surface "customer-card|Customer card|lib/view/new_widgets/customer_widget.dart"

Requires Pillow built with libraqm, because half of these images are Arabic and the per-tile labels
carry Arabic text: without shaping, `العربية` renders as disconnected letters in the wrong order.
`PIL.features.check('raqm')` is asserted below rather than assumed.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, features

# The four combinations every surface in this project is captured in, in the order a reviewer reads
# them: the two light ones, then the two dark ones. Matches `kFourCombinations` in
# test/support/golden_harness.dart.
COMBINATIONS = [
    ("light-ltr", "English", "LTR", "Light"),
    ("light-rtl", "العربية", "RTL", "Light"),
    ("dark-ltr", "English", "LTR", "Dark"),
    ("dark-rtl", "العربية", "RTL", "Dark"),
]

TILE_W = 360          # the harness surface width; images are placed at 1:1, never rescaled
GAP = 16
MARGIN = 18
HEADER_TOP = 64      # title + subtitle; the notes grow the band below this
NOTE_H = 16
LABEL_H = 34
SECTION_H = 46

INK = (15, 26, 46)
MUTED = (110, 120, 135)
PAPER = (255, 255, 255)
BAND = (15, 26, 46)
BAND_INK = (255, 255, 255)
BAND_MUTED = (150, 200, 230)
HAIRLINE = (190, 198, 210)

# The app's own typeface, so the sheet is set in the same family as the pictures on it.
FONT_DIR = Path(__file__).resolve().parent.parent / "assets" / "fonts"
FALLBACK_FONT_DIR = Path("/usr/share/fonts/truetype/dejavu")


def _font(weight: str, size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        FONT_DIR / f"Tajawal-{weight}.ttf",
        FALLBACK_FONT_DIR / ("DejaVuSans-Bold.ttf" if weight != "Regular" else "DejaVuSans.ttf"),
    ]
    for path in candidates:
        if path.exists():
            return ImageFont.truetype(str(path), size)
    raise SystemExit(f"no font found for weight {weight}; looked in {FONT_DIR} and {FALLBACK_FONT_DIR}")


def content_bottom(image: Image.Image) -> int:
    """The last row that is not the page background, i.e. where the rendered content ends.

    The page colour is read from the BOTTOM-left pixel, not the top-left: content is aligned to
    `AlignmentDirectional.topStart` by the harness, so the top-left pixel can be inside the card's
    own rounded corner while the bottom-left is always page.
    """
    rgb = image.convert("RGB")
    width, height = rgb.size
    page = rgb.getpixel((0, height - 1))
    pixels = rgb.load()

    for y in range(height - 1, -1, -1):
        for x in range(width):
            r, g, b = pixels[x, y]
            if abs(r - page[0]) > 2 or abs(g - page[1]) > 2 or abs(b - page[2]) > 2:
                return y

    return 0


def parse_surface(spec: str) -> tuple[str, str, str]:
    parts = spec.split("|")
    if len(parts) != 3:
        raise SystemExit(f'--surface wants "slug|Title|source/path.dart", got "{spec}"')
    return parts[0], parts[1], parts[2]


def main(argv: list[str]) -> int:
    if not features.check("raqm"):
        raise SystemExit(
            "Pillow has no libraqm, so the Arabic labels on this sheet would render as "
            "disconnected letters in visual order. Install libraqm and rebuild Pillow."
        )

    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--images-dir", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", default="Flutter route 1 — GOLDEN CANDIDATES, NOT APPROVED BASELINES")
    ap.add_argument(
        "--subtitle",
        default="Awaiting human review (step 2 of 3). Nothing here is committed to "
        "test/golden/goldens as a baseline.",
    )
    ap.add_argument("--note", action="append", default=[])
    ap.add_argument("--surface", action="append", required=True)
    ap.add_argument("--page-margin", type=int, default=46,
                    help="rows of page background kept under the tallest content in each row")
    args = ap.parse_args(argv)

    images_dir = Path(args.images_dir)
    surfaces = [parse_surface(s) for s in args.surface]

    # Load every tile first: the sheet's height depends on what the pictures contain.
    rows: list[tuple[str, str, str, list[tuple[str, Image.Image]]]] = []
    for slug, title, source in surfaces:
        tiles = []
        for name, _lang, _dir_, _theme in COMBINATIONS:
            path = images_dir / f"{slug}.{name}.png"
            if not path.exists():
                raise SystemExit(f"missing capture: {path}")
            tiles.append((name, Image.open(path).convert("RGB")))
        rows.append((slug, title, source, tiles))

    row_heights = [
        min(
            max(content_bottom(img) for _, img in tiles) + args.page_margin,
            tiles[0][1].size[1],
        )
        for _, _, _, tiles in rows
    ]

    header_h = HEADER_TOP + NOTE_H * len(args.note) + 8
    width = MARGIN * 2 + TILE_W * 4 + GAP * 3
    height = header_h + sum(SECTION_H + h + LABEL_H + GAP for h in row_heights) + MARGIN

    sheet = Image.new("RGB", (width, height), PAPER)
    draw = ImageDraw.Draw(sheet)

    f_title = _font("Bold", 21)
    f_sub = _font("Medium", 14)
    f_note = _font("Regular", 12)
    f_section = _font("Bold", 16)
    f_label = _font("Bold", 13)
    f_file = _font("Regular", 11)

    draw.rectangle([0, 0, width, header_h], fill=BAND)
    draw.text((MARGIN, 14), args.title, font=f_title, fill=BAND_INK)
    draw.text((MARGIN, 42), args.subtitle, font=f_sub, fill=BAND_MUTED)
    for i, note in enumerate(args.note):
        draw.text((MARGIN, HEADER_TOP + i * NOTE_H), note, font=f_note, fill=(185, 195, 210))

    y = header_h + 12
    for (slug, title, source, tiles), row_h in zip(rows, row_heights):
        draw.text((MARGIN, y), title, font=f_section, fill=INK)
        draw.text((MARGIN, y + 21), source, font=f_file, fill=MUTED)
        y += SECTION_H

        for col, ((name, img), (_n, lang, direction, theme)) in enumerate(zip(tiles, COMBINATIONS)):
            x = MARGIN + col * (TILE_W + GAP)
            sheet.paste(img.crop((0, 0, TILE_W, row_h)), (x, y))
            draw.rectangle([x, y, x + TILE_W - 1, y + row_h - 1], outline=HAIRLINE)
            draw.text((x, y + row_h + 7), f"{lang}  ·  {direction}  ·  {theme}",
                      font=f_label, fill=INK)
            draw.text((x, y + row_h + 21), f"{slug}.{name}.png", font=f_file, fill=MUTED)

        y += row_h + LABEL_H + GAP

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"{out}  {width}x{height}  "
          f"{len(rows)} surfaces x {len(COMBINATIONS)} combinations = {len(rows) * 4} images")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
