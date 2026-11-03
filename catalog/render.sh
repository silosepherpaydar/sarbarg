#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
RAW="/tmp/silo-catalog-raw.png"
# A4 portrait at 1080×1528 CSS px, captured at 2x
google-chrome-stable \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --allow-file-access-from-files \
  --hide-scrollbars \
  --force-device-scale-factor=2 \
  --window-size=1080,1528 \
  --virtual-time-budget=8000 \
  --screenshot="${RAW}" \
  "file://$(pwd)/index.html"

python3 - <<'PY'
from PIL import Image
im = Image.open("/tmp/silo-catalog-raw.png").convert("RGB")
# Exact A4 capture; trim only if chrome added a sliver
w, h = im.size
im.save("silo-price-list-aban@2x.png", optimize=True)
send = im.resize((1080, round(h * 1080 / w)), Image.Resampling.LANCZOS)
send.save("silo-price-list-aban.png", optimize=True)
# keep previous filename as alias for the sendable A4 sheet
send.save("silo-price-list-mehr.png", optimize=True)
im.save("silo-price-list-mehr@2x.png", optimize=True)
print("2x", im.size)
print("1x", send.size)
print("ratio", round(send.size[1] / send.size[0], 3), "A4=", round(297/210, 3))
PY
