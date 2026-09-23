#!/usr/bin/env bash
# Build the arXiv upload bundle of the English paper (docs/paper/degree_labeling.tex).
#
# arXiv flattens the upload and does not run BibTeX, so the bundle carries the .tex and
# the locally generated .bbl side by side, and nothing else. The repository build keeps
# reading ../references.bib; only the bundle uses the .bbl.
#
# Output (untracked, under the ignored /build/):
#   build/arxiv/src/                 flat source directory (degree_labeling.tex, .bbl)
#   build/arxiv/degree_labeling.tar.gz  the same files, ready to upload
#
# The bundle is verified in a fresh directory with pdflatex alone (no BibTeX); an
# undefined citation or reference fails the script.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME=degree_labeling
PAPER="$ROOT/docs/paper"
OUT="$ROOT/build/arxiv"

for tool in latexmk pdflatex bibtex tar; do
  command -v "$tool" >/dev/null 2>&1 || { echo "arxiv-bundle: missing $tool" >&2; exit 1; }
done

# 1. Build in a scratch copy of docs/ so the working tree gets no by-products.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/docs/paper"
cp "$ROOT/docs/references.bib" "$work/docs/"
cp "$PAPER/$NAME.tex" "$work/docs/paper/"
# -norc: a personal ~/.latexmkrc (e.g. an $out_dir) must not change where the .bbl lands;
# the options below are those of docs/paper/latexmkrc.
(cd "$work/docs/paper" && latexmk -norc -pdf -bibtex -interaction=nonstopmode -halt-on-error "$NAME.tex" >/dev/null) \
  || { echo "arxiv-bundle: latexmk failed; see a local latexmk run in docs/paper" >&2; exit 1; }
test -s "$work/docs/paper/$NAME.bbl" || { echo "arxiv-bundle: no .bbl produced" >&2; exit 1; }

# 2. Assemble the flat bundle.
rm -rf "$OUT"
mkdir -p "$OUT/src"
cp "$work/docs/paper/$NAME.tex" "$work/docs/paper/$NAME.bbl" "$OUT/src/"

# 3. Verify: fresh directory, no BibTeX, pdflatex rerun until labels settle (arXiv's
#    AutoTeX does the same), at most 4 passes.
mkdir "$work/verify"
cp "$OUT/src/"* "$work/verify/"
passes=0
while :; do
  passes=$((passes + 1))
  (cd "$work/verify" && pdflatex -interaction=nonstopmode -halt-on-error "$NAME.tex" >/dev/null) \
    || { echo "arxiv-bundle: pdflatex failed on the bundle (pass $passes)" >&2; exit 1; }
  grep -q 'Rerun to get' "$work/verify/$NAME.log" || break
  [ "$passes" -lt 4 ] || { echo "arxiv-bundle: labels still unstable after $passes passes" >&2; exit 1; }
done
if grep -nE 'undefined' "$work/verify/$NAME.log"; then
  echo "arxiv-bundle: unresolved citations or references in the bundle build" >&2
  exit 1
fi
echo "arxiv-bundle: bundle compiles with pdflatex x$passes, no BibTeX"
cp "$work/verify/$NAME.pdf" "$OUT/$NAME.pdf"

# 4. Package.
tar -czf "$OUT/$NAME.tar.gz" -C "$OUT/src" "$NAME.tex" "$NAME.bbl"
echo "arxiv-bundle: $OUT/$NAME.tar.gz"
tar -tzf "$OUT/$NAME.tar.gz"
