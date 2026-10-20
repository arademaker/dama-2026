/- Onde a CSLib está hoje: um slide de topo do deck, incluído por `Slides.lean`. -/
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

#doc (Slides) "Onde a CSLib está hoje" =>

%%%
vertical := true
%%%

Quinze meses e meio depois do primeiro commit:

:::table +colHeaders +rowSeps
*
  * Métrica
  * Valor
*
  * Arquivos Lean em `Cslib/`
  * 253
*
  * Linhas não vazias
  * 33,727
*
  * Teoremas e lemas
  * 2,579
*
  * Definições, estruturas, classes
  * 1,179
*
  * Contribuidores
  * 57
*
  * Pull requests aceitos
  * 622
*
  * Estrelas / forks no GitHub
  * 728 / 202
:::

`leanprover/cslib`, `main` em `c149a9d` (2026-10-01).

:::notes
Counts from `cslib-stats.md`, with comments stripped before counting
declarations. Contributors are distinct people who authored or co-authored a
commit, plus six credited only in file headers; bots excluded. In the last two
weeks alone: 64 commits and 17% more lines. The code slides elaborate against
the slightly older pin `12ba7cf`.
:::

# O que tem dentro

:::table +colHeaders +rowSeps
*
  * Área
  * Linhas
  * Destaques
*
  * `Computability`
  * 12,319
  * Autômatos, máquinas de Turing, URM, circuitos, FLP
*
  * `Foundations`
  * 7,836
  * LTS, bissimulação, relações, mônadas, dados, sintaxe
*
  * `Languages`
  * 7,004
  * Cálculos λ, F<:, CCS, coreografias, processos
*
  * `Logics`
  * 3,327
  * Linear, modal, HML, proposicional
*
  * `Crypto`
  * 1,423
  * Sigilo perfeito, compartilhamento de segredos, PRGs
*
  * `MachineLearning`
  * 872
  * Aprendizado PAC, dimensão VC
*
  * `Algorithms`
  * 660
  * Mônada de tempo, ordenação, Diffie–Hellman
*
  * `Probability`
  * 251
  * PMF, distância estatística
:::

:::notes
Computability is now the largest area, 36.5% of the lines, and took
most of the recent growth: Sam Schlesinger's Boolean circuits, with Shannon's
lower bound and Lupanov's construction, and Christian Reitwiessner's
multi-tape Turing machines. Automata include two-way and ω-automata.
Lines are non-empty lines of `Cslib/` at `c149a9d`; Languages also has
stateful processes. Not shown: `Tactic` (1 file, 18 lines) and the
root `Init.lean`. File counts: Computability 92, Foundations 69, Languages
45, Logics 19, Crypto 14, Algorithms 6, MachineLearning 4, Probability 2;
253 in all.
:::
