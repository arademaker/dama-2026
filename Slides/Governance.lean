/- Governance: a top-level slide of the deck, included by `Slides.lean`. -/
module

public import VersoSlides

open VersoSlides

-- Without the info panel a code box fits about 85 columns; keep a margin.
set_option verso.code.warnLineLength 80
-- No block produces a proof state worth showing, and the panel costs half the
-- slide width. Re-enable per block with `+panel`.
set_option verso.slides.panel false
set_option linter.unusedVariables false
set_option maxHeartbeats 1000000

#doc (Slides) "Governance" =>

%%%
vertical := true
%%%

CSLib lives in the [leanprover](https://github.com/leanprover) GitHub organisation, next to Lean itself. The steering committee guides the vision and secures support:

- Clark Barrett (Stanford, Amazon)
- Swarat Chaudhuri (Google DeepMind, UT Austin)
- Jim Grundy (Amazon)
- Pushmeet Kohli (Google DeepMind)
- Leonardo de Moura (Lean FRO, Amazon)
- Fabrizio Montesi (FORM, University of Southern Denmark)

:::notes
10:10. Roster and affiliations as published on cslib.io/governance (source:
`Lang/Components/TeamData.lean` in cslib-community.github.io). Press down for
the maintainers.
:::

# Maintainers

The maintainers own the codebase and its technical direction. Lead
maintainer: Fabrizio Montesi. Technical leads: Alexandre Rademaker (Logic), Sorrachai
Yingchareonthawornchai (Algorithms and data structures).

Area maintainers:

- Chris Henson (Drexel): λ-calculus, metaprogramming
- Kim Morrison (Lean FRO): CI/CD with Lean and Mathlib
- Samuel Schlesinger (Google): Complexity, cryptography, learning theory
- Christian Reitwiessner: Complexity
- and the technical leads

New members are invited on project need and merit.

:::notes
10:55. Area maintainers own an area of the codebase, as subject-matter experts
and reviewers. The two technical leads also maintain an area each. Christian
Reitwiessner has no affiliation listed on the site.
:::
