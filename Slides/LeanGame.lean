/- O Lean é um "jogo": um slide de topo do deck, incluído por `Slides.lean`. -/
module

public import VersoSlides
-- The `diagram` blocks elaborate Illuminate terms.
import Illuminate -- shake: keep
import Verso.Doc.Concrete
-- `public`: the elaborated ```lean blocks cannot see a module's private imports.
public import Cslib.Foundations.Semantics.LTS.Bisimulation
public import Cslib.Languages.CCS.Semantics
public import Cslib.Languages.CCS.BehaviouralTheory
public import Cslib.Logics.HML.Basic
public import Cslib.Algorithms.Lean.MergeSort.MergeSort
-- `meta` too: the `#eval`s and `native_decide` run CSLib's `TimeM` code.
public meta import Cslib.Algorithms.Lean.MergeSort.MergeSort
public import Cslib.Computability.Automata.DA.Basic
public import Cslib.Computability.Automata.NA.Basic
public import Cslib.Computability.Automata.Acceptors.Acceptor

open VersoSlides

-- Without the info panel a code box fits about 85 columns; keep a margin.
set_option verso.code.warnLineLength 80
-- No block produces a proof state worth showing, and the panel costs half the
-- slide width. Re-enable per block with `+panel`.
set_option verso.slides.panel false
set_option linter.unusedVariables false
set_option maxHeartbeats 1000000

#doc (Slides) "O Lean é um \"jogo\"" =>

```lean +panel
/- !hide -/
namespace LeanIntro
/- !end hide -/
def odd (n : Nat) : Prop := ∃ k, n = 2 * k + 1

theorem square_of_odd_is_odd : odd n → odd (n * n) := by
  intro ⟨k₁, e₁⟩
  simp [e₁, odd]
  exists 2 * k₁ * k₁ + 2 * k₁
  lia
/- !hide -/
end LeanIntro
/- !end hide -/
```

O "tabuleiro": você vê as metas e as hipóteses, e faz "jogadas" (táticas).
*Cada tática transforma o tabuleiro.*

:::attr («class» := "credits")
Exemplo do deck FROCON 2026 de Leo de Moura ([@leodemoura](https://github.com/leodemoura)).
:::

:::notes
Clique em cada tática: o painel à direita mostra as metas e hipóteses que
ela deixa. `intro` desmonta a hipótese "n é ímpar" em `k₁` e `e₁`; `simp`
reescreve; `exists` escolhe a testemunha; `lia` fecha a aritmética. Vá
devagar aqui: é a primeira prova "de verdade" da palestra.
:::
