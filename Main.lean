module

import VersoSlides
import Slides

open VersoSlides

/-- CSLib's identity from cslib.io: Open Sans, the sienna palette, and the
brown hero gradient on section breaks. Left-aligned slides, as in
`sviL-hackathon-2026`. -/
def customCss : CssFile where
  filename := "custom.css"
  contents := ⟨include_str "static/custom.css"⟩

def config : Config := {
  theme       := "white",
  center      := false,
  margin      := 0,
  -- 16:9, as a projector is. verso-slides defaults to 960×700, which leaves
  -- empty bands at the sides and squeezes side-by-side layouts (`hstack`).
  width       := 1280,
  height      := 720,
  slideNumber := true,
  transition  := "fade",
  extraCss    := #[customCss]
}

/-- The title slide. The layout is the two-part one of Leo de Moura's FROCON
2026 deck: a logo on white, then a band with the title, the speaker and
affiliation, and the venue and date at the bottom. The identity is CSLib's,
from the www.cslib.io sources (`~/r/cslib-community.github.io`): the brown
gradient of its home-page hero. This talk is about Lean in general, so the
logo on white is Lean's (`static/images/lean-logo.png`), not CSLib's. The styles are
`.title-slide` in `static/custom.css`.

Verso markdown cannot emit this markup, so `main` swaps it in for the first
section-break slide of the rendered deck. The first slide of `Slides.lean`
holds the same text, and is what you see if the swap ever stops matching.
Keep the two in sync.

The background is two layers over the whole window: white down to 25%, then
the CSLib gradient. The edge sits at the same 25% as `.title-slide .top-area`,
and the two line up whenever the window is at least 16:9, as a projector is.
(Leo's deck gets a full-bleed band from `disableLayout`, but that also stops
reveal.js from scaling every other slide.) -/
def titleSlide : String :=
  "<section class=\"title-slide\" data-background-gradient=\"" ++
  "linear-gradient(to bottom, #ffffff 0%, #ffffff 25%, transparent 25%), " ++
  "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)\">\n" ++
  "  <div class=\"top-area\"><img class=\"logo\" src=\"lean-logo.png\" alt=\"Lean\"></div>\n" ++
  "  <div class=\"title-band\">\n" ++
  "    <h1>Lean 4: matemática, código e IA no mesmo lugar</h1>\n" ++
  "    <div class=\"meta\"><strong>Alexandre Rademaker</strong><br>" ++
  "FGV/EMAp</div>\n" ++
  "    <div class=\"date\">V SEEMAp, FGV EMAp | 21 de outubro de 2026<br>" ++
  "<a class=\"url\" href=\"https://arademaker.github.io/dama-2026/\">" ++
  "arademaker.github.io/dama-2026</a></div>\n" ++
  "  </div>\n" ++
  "</section>"

/-- How every section-break slide opens in the rendered HTML. -/
def breakOpen : String := "<section data-background-gradient=\""

/-- Replace the first section-break slide of `html` with `titleSlide`. -/
def swapTitleSlide (html : String) : Except String String :=
  match html.splitOn breakOpen with
  | before :: first :: rest =>
    match first.splitOn "</section>" with
    | _ :: after@(_ :: _) =>
      let tail := "</section>".intercalate after
      .ok (before ++ titleSlide ++ tail ++ String.join (rest.map (breakOpen ++ ·)))
    | _ => .error "the first section break has no closing tag"
  | _ => .error "no section break found for the title slide"

/-- Open external links in a new tab, so following one during the talk does not
navigate away from the deck. Verso renders every Markdown link as a bare
`<a href="…">`; only absolute `http(s)` ones are touched. -/
def externalLinksInNewTab (html : String) : String :=
  html.replace "<a href=\"http" "<a target=\"_blank\" rel=\"noopener\" href=\"http"

/-- verso-slides sizes each `diagram` as `width: <n>vw`, assuming the slide is
the whole window. Here reveal.js scales a 1280×720 slide to the window, so a
viewport unit would scale twice and the diagram would drift against the text
on another screen. Rewrite the width in slide pixels: 1vw of the slide is
12.8px. -/
def diagramWidthsInSlidePixels (html : String) : String :=
  match html.splitOn "style=\"width: " with
  | [] => html
  | first :: rest =>
    first ++ String.join (rest.map fun piece =>
      match piece.splitOn "vw;" with
      | num :: after@(_ :: _) =>
        match toMillionths num with
        | some m => "style=\"width: " ++ toString ((m * 128 + 5000000) / 10000000) ++ "px;" ++
            "vw;".intercalate after
        | none => "style=\"width: " ++ piece
      | _ => "style=\"width: " ++ piece)
where
  /-- `"25.880000"` ↦ `25880000`; `none` unless digits, a dot, six digits. -/
  toMillionths (s : String) : Option Nat :=
    match s.splitOn "." with
    | [i, f] =>
      if f.length == 6 && (i ++ f).all Char.isDigit && !i.isEmpty then
        some (i.toNat! * 1000000 + f.toNat!)
      else none
    | _ => none

public def main : IO UInt32 := do
  let rc ← slidesMain (config := config) (doc := %doc Slides)
  if rc != 0 then return rc
  let out := config.outputDir
  IO.FS.writeBinFile (out / "lean-logo.png") (← IO.FS.readBinFile "static/images/lean-logo.png")
  -- `include_str` above is only re-read when this file recompiles, so a CSS
  -- edit alone would ship a stale stylesheet. Copy the current one.
  IO.FS.writeFile (out / customCss.filename) (← IO.FS.readFile "static/custom.css")
  let htmlPath := out / "index.html"
  match swapTitleSlide (← IO.FS.readFile htmlPath) with
  | .ok html =>
    IO.FS.writeFile htmlPath (diagramWidthsInSlidePixels (externalLinksInNewTab html)); return 0
  | .error e => IO.eprintln s!"title slide: {e}"; return 1
