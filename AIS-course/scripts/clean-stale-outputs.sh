#!/usr/bin/env bash
# CNI's schedule links lectures 7–10 as lecture-0x.qmd. GitHub Pages serves
# *.qmd as downloads, so those files must not exist in the published site.
# Missing paths then hit 404.html, which redirects to the rendered lectures.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
book="$root/_book"

# Ensure the custom 404 is at the site root (also listed under project.resources).
cp -f "$root/404.html" "$book/404.html"

# Drop any leftover or alias-generated *.qmd under lectures/.
rm -f "$book"/lectures/*.qmd

# Keep Quarto HTML aliases (lecture-0x.html → renamed lectures).
