# The exe name comes from `lakefile.toml`'s `[[lean_exe]]`.
EXE := dama-2026

# Modules quoted by `leanLibCode` blocks in Slides/, as Lake facet keys.
# Each one's SubVerso `highlighted` facet is built before the deck elaborates.
# This avoids duplicate racing jobs (see #15435)
QUOTED := @cslib/+Cslib.Algorithms.Lean.MergeSort.MergeSort \
          @cslib/+Cslib.Languages.CCS.Semantics \
          @cslib/+Cslib.Logics.HML.Basic

.PHONY: all slides highlighted serve cache clean demo roteiro

all: slides

# Builds the highlighted code needed to quote library sources
highlighted:
	lake build $(foreach m,$(QUOTED),'$(m):highlighted')

# Writes _slides/index.html. Depends on the whole Lake build, so the first
# run compiles CSLib from source.
slides: highlighted
	lake exe $(EXE)

# reveal.js needs to be served over HTTP; opening index.html from the
# filesystem leaves the vendored assets unreachable. `verso-serve` is
# Verso's own development server, so no separate one is needed.
serve: slides
	lake exe verso-serve _slides

# Mathlib binaries. Reaches us through cslib; see the require order note in
# lakefile.toml for why this is expected to succeed rather than fall back to
# building from source.
cache:
	lake exe cache get

# The live demo's answer key and its per-step snapshots must still compile
# with this toolchain. Not part of the `Slides` library: the live file is meant
# to be incomplete, and Etapa5 ends on a `grind` failure on purpose.
DEMO_OK := Demo/BinSearch.lean $(foreach n,1 2 3 4 6 7,Demo/Etapas/Etapa$(n).lean)

demo:
	@for f in $(DEMO_OK); do echo "lake env lean $$f"; lake env lean $$f || exit 1; done

# ROTEIRO.pdf, to print: pandoc renders the Markdown with a print style, and
# headless Chrome writes the PDF. Not versioned; run again after editing.
CHROME := /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
roteiro:
	pandoc ROTEIRO.md --standalone --embed-resources --css scripts/roteiro-print.css \
	  --metadata pagetitle="Roteiro" -o _roteiro.html
	"$(CHROME)" --headless --disable-gpu --no-pdf-header-footer \
	  --print-to-pdf=ROTEIRO.pdf _roteiro.html
	rm -f _roteiro.html

clean:
	rm -rf _slides
