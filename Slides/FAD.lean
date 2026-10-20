/- A textbook that uses CSLib: FAD: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "A textbook that uses CSLib: FAD" =>

[cslib-community/fad](https://github.com/cslib-community/fad): Bird and Gibbons' [Algorithm Design with Haskell](https://www.cs.ox.ac.uk/publications/books/adwh/), in Lean, taught at FGV/EMAp. We are starting to adapt it to [Verso](https://verso.lean-lang.org) and to use CSLib's defs like `TimeM`:

```lean -stretch
/- !hide -/
namespace FAD
open Cslib.Algorithms.Lean TimeM
/- !end hide -/
def maxM (x y : ℕ) : TimeM ℕ ℕ := do ✓ pure (max x y)

def maximumM : List ℕ → TimeM ℕ ℕ
  | []           => pure 0
  | [x]          => pure x
  | x :: y :: ys => do maxM x (← maximumM (y :: ys))

/-- The maximum of `n` numbers takes `n - 1` comparisons. -/
theorem time_maximum (xs : List ℕ) : (maximumM xs).time = xs.length - 1 := by
  fun_induction maximumM <;> simp_all [maxM]
/- !hide -/
end FAD
/- !end hide -/
```

Beyond `TimeM`, two open proposals for a query-complexity model, [#401](https://github.com/leanprover/cslib/pull/401) (Kim Morrison) and [#685](https://github.com/leanprover/cslib/pull/685) (Shreyas Srinivas), derive costs from the operations a program performs: useful for amortised running times (ADwH §2.4).

:::notes
42:20. Condensed from `Fad/Chapter6.lean` (Bird and Gibbons 6.1), where a
student wrote it with a `foldr1M` helper. Students are co-authors of the
book. FAD is the cleanest example today of a
downstream project importing CSLib.
:::
