#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
RAW="/tmp/silo-catalog-raw.png"
google-chrome-stable \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --allow-file-access-from-files \
  --hide-scrollbars \
  --force-device-scale-factor=2 \
  --window-size=1080,2400 \
  --virtual-time-budget=8000 \
  --screenshot="${RAW}" \
  "file://$(pwd)/index.html"

python3 - <<'PY'
from PIL import Image
im = Image.open("/tmp/silo-catalog-raw.png").convert("RGB")
w, h = im.size
px = im.load()

def is_trailing(y):
    # trailing empty paper under the dark footer
    papers = 0
    darks = 0
    n = 0
    for x in range(0, w, 8):
        r, g, b = px[x, y]
        n += 1
        if r > 228 and g > 222 and b > 210:
            papers += 1
        if r < 80 and g < 80 and b < 80:
            darks += 1
    return papers > n * 0.92 and darks < n * 0.05

maxy = h - 1
while maxy > 0 and is_trailing(maxy):
    maxy -= 1

crop = im.crop((0, 0, w, maxy + 1))
crop.save("silo-price-list-mehr@2x.png", optimize=True)
send = crop.resize((1080, round(crop.size[1] * 1080 / crop.size[0])), Image.Resampling.LANCZOS)
send.save("silo-price-list-mehr.png", optimize=True)
print("2x", crop.size)
print("1x", send.size)
PY
