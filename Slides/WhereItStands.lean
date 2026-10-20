/- Where it stands today: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "Where it stands today" =>

%%%
vertical := true
%%%

Fifteen and a half months after the first commit:

:::table +colHeaders +rowSeps
*
  * Metric
  * Value
*
  * Lean files in `Cslib/`
  * 253
*
  * Non-empty lines
  * 33,727
*
  * Theorems and lemmas
  * 2,579
*
  * Definitions, structures, classes
  * 1,179
*
  * Contributors
  * 57
*
  * Merged pull requests
  * 622
*
  * GitHub stars / forks
  * 728 / 202
:::

`leanprover/cslib` `main` at `c149a9d` (2026-10-01).

:::notes
8:40. Counts from `cslib-stats.md`, with comments stripped before counting
declarations. Contributors are distinct people who authored or co-authored a
commit, plus six credited only in file headers; bots excluded. In the last two
weeks alone: 64 commits and 17% more lines. The code slides elaborate against
the slightly older pin `12ba7cf`.
:::

# What is in it

:::table +colHeaders +rowSeps
*
  * Area
  * Lines
  * Highlights
*
  * `Computability`
  * 12,319
  * Automata, Turing machines, URM, circuits, FLP
*
  * `Foundations`
  * 7,836
  * LTS, bisimulation, relations, monads, data, syntax
*
  * `Languages`
  * 7,004
  * λ-calculi, F<:, CCS, choreographies, processes
*
  * `Logics`
  * 3,327
  * Linear, modal, HML, propositional
*
  * `Crypto`
  * 1,423
  * Perfect secrecy, secret sharing, commitments, PRGs
*
  * `MachineLearning`
  * 872
  * PAC learning, VC dimension
*
  * `Algorithms`
  * 660
  * Time monad, sorting, Diffie–Hellman
*
  * `Probability`
  * 251
  * PMF, statistical distance
:::

:::notes
9:25. Computability is now the largest area, 36.5% of the lines, and took
most of the recent growth: Sam Schlesinger's Boolean circuits, with Shannon's
lower bound and Lupanov's construction, and Christian Reitwiessner's
multi-tape Turing machines. Automata include two-way and ω-automata.
Lines are non-empty lines of `Cslib/` at `c149a9d`; Languages also has
stateful processes. Not shown: `Tactic` (1 file, 18 lines) and the
root `Init.lean`. File counts: Computability 92, Foundations 69, Languages
45, Logics 19, Crypto 14, Algorithms 6, MachineLearning 4, Probability 2;
253 in all.
:::
