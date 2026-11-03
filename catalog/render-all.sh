#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

render_one() {
  local src="$1"
  local stem="$2"
  local raw="/tmp/silo-catalog-${stem}.png"
  google-chrome-stable \
    --headless=new \
    --disable-gpu \
    --no-sandbox \
    --allow-file-access-from-files \
    --hide-scrollbars \
    --force-device-scale-factor=2 \
    --window-size=1080,1528 \
    --virtual-time-budget=8000 \
    --screenshot="${raw}" \
    "file://$(pwd)/${src}" >/dev/null
  python3 - "$raw" "$stem" <<'PY'
import sys
from PIL import Image
raw, stem = sys.argv[1], sys.argv[2]
im = Image.open(raw).convert("RGB")
im.save(f"{stem}@2x.png", optimize=True)
send = im.resize((1080, round(im.size[1] * 1080 / im.size[0])), Image.Resampling.LANCZOS)
send.save(f"{stem}.png", optimize=True)
print(stem, send.size)
PY
}

# official saved sheet
render_one "index.html" "silo-price-list-aban"
cp -f silo-price-list-aban.png silo-price-list-mehr.png
cp -f silo-price-list-aban@2x.png silo-price-list-mehr@2x.png

render_one "model-a-gray.html" "preview-a-gray"
render_one "model-b-orange.html" "preview-b-orange"
render_one "model-c-soft.html" "preview-c-soft"
render_one "model-d-atelier.html" "preview-d-atelier"
