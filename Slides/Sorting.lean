/- Your program is already a specification: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "Your program is already a specification" =>

%%%
vertical := true
%%%

To check that a fast program is correct, we need a specification. Often the
simplest program that does the job *is* that specification: obviously correct,
but too slow to use.

- *Specification:* insertion sort, six lines, nothing clever.
- *Implementation:* CSLib's verified `mergeSort`, standing in for the optimised
  version an engineer, or an AI agent, would write.
- *Goal:* prove they return the same output on every input, and count how many
  comparisons each one makes.

Both are written in CSLib's *time monad* `TimeM`: a program returns its result
together with a cost, and each `✓` charges one comparison.

:::attr («class» := "credits")
Example: Jesse Alama ([@jessealama](https://github.com/jessealama)). CSLib authors: Sorrachai ([@sorrachai](https://github.com/sorrachai)), Eric Wieser ([@eric-wieser](https://github.com/eric-wieser)), Kim Morrison ([@kim-em](https://github.com/kim-em)).
:::

:::notes
30:45. Insertion sort is the specification: six lines, nothing clever.
`mergeSort` stands in for the optimised version an engineer, or an AI agent,
would write. Both return the answer and the number of comparisons.
:::

# ...the obvious sort

```lean -stretch
/- !hide -/
open Cslib.Algorithms.Lean TimeM
/- !end hide -/
variable {α : Type} [LinearOrder α]

def insertSorted (x : α) : List α → TimeM ℕ (List α)
  | [] => return [x]
  | y :: ys => do
    ✓ let c := (x ≤ y : Bool)
    if c then return x :: y :: ys
    else return y :: (← insertSorted x ys)

def insertionSort : List α → TimeM ℕ (List α)
  | [] => return []
  | x :: xs => do insertSorted x (← insertionSort xs)
```

:::notes
31:30. The tick is the only thing that is not textbook insertion sort: it charges
one unit of time. The cost model is explicit and trusted: CSLib's `TimeM`
documentation says so.
:::

# ...same answer, different bill

```lean -stretch
#eval ⟪insertionSort [5, 3, 1, 4, 2]⟫
#eval ⟪mergeSort [5, 3, 1, 4, 2]⟫
#eval (insertionSort (List.range 1000).reverse).time
#eval (mergeSort (List.range 1000).reverse).time
```

:::notes
32:15. The outputs are computed at build time. On 1000 reversed elements:
499,500 comparisons versus 4,932.
:::

# ...connected to Mathlib

`⟪p⟫` drops the cost and keeps the result. Without its cost, our insertion
sort is Mathlib's `List.insertionSort`:

```lean -stretch
@[simp, grind =]
theorem ret_insertSorted (x : α) (l : List α) :
    ⟪insertSorted x l⟫ = l.orderedInsert (· ≤ ·) x := by
  fun_induction insertSorted with grind

@[simp, grind =]
theorem ret_insertionSort (xs : List α) :
    ⟪insertionSort xs⟫ = xs.insertionSort (· ≤ ·) := by
  fun_induction insertionSort with grind
```

Why Mathlib's definitions: Mathlib already proves that `List.insertionSort`
returns a sorted permutation of its input. One bridge lemma, and we reuse
those proofs instead of redoing them.

:::attr («class» := "credits")
Mathlib authors: Jeremy Avigad ([@avigad](https://github.com/avigad)), Wrenna Robson ([@wrenna-robson](https://github.com/wrenna-robson)).
:::

:::notes
33:00. `List.orderedInsert` and `List.insertionSort` are Mathlib's untimed
definitions. Same policy as on the "unified library" slide: do not rebuild
what Mathlib already has. `grind` closes both inductions.
:::

# ...equivalent, for every input

Both outputs are sorted permutations of the input, and a list has only one
sorted permutation:

```lean -stretch
/-- The fast one agrees with the obvious one. Not tested. Proved. -/
theorem mergeSort_eq_insertionSort (xs : List α) :
    ⟪mergeSort xs⟫ = ⟪insertionSort xs⟫ := by
  obtain ⟨hs, hp⟩ := mergeSort_correct xs
  simpa using List.Perm.eq_of_sortedLE hs.sortedLE List.sortedLE_insertionSort
    (hp.trans (List.perm_insertionSort _ xs).symm)
```

- From CSLib: `mergeSort_correct`, the output of `mergeSort` is sorted and a
  permutation of `xs`.
- From Mathlib: `List.sortedLE_insertionSort` and `List.perm_insertionSort`,
  the same for insertion sort; and `List.Perm.eq_of_sortedLE`, two sorted
  lists that are permutations of each other are equal.

:::notes
34:00. The checker, not code review, accepts the optimised version.
:::

# ...and the cost of `insertionSort` is `n²`

```lean -stretch
theorem insertSorted_time (x : α) (l : List α) :
    (insertSorted x l).time ≤ l.length := by
  fun_induction insertSorted with grind

@[simp] theorem insertionSort_length (xs : List α) :
    ⟪insertionSort xs⟫.length = xs.length := by
  simp

theorem insertionSort_time (xs : List α) :
    (insertionSort xs).time ≤ xs.length ^ 2 := by
  fun_induction insertionSort <;> simp
  grind [insertSorted_time, insertionSort_length]
```

The `mergeSort` is `n ⌈log₂ n⌉` as proved in CSLib

```leanLibCode Cslib.Algorithms.Lean.MergeSort.MergeSort (startLine := 187) (endLine := 190) -stretch
theorem mergeSort_time (xs : List α) :
    let n := xs.length
    (mergeSort xs).time ≤ n * clog 2 n := by
  grind [mergeSort_time_le, timeMergeSortRec_le]
```

:::notes
35:00. One insertion costs at most the length of the list, sorting preserves
length, so insertion sort makes at most n² comparisons. `clog 2 n` is ⌈log₂ n⌉. In lean-zip, AI agents could optimise aggressively because every change had to keep the correctness theorem. With the time monad, performance claims can be theorems too.
:::

# ...and the checker says no

The exact worst case for insertion sort is accepted:

```lean -stretch
set_option maxRecDepth 4000 in
example :
    (insertionSort (List.range 100).reverse).time = 100 * 99 / 2 := by
  decide
```

A false claim about merge sort is refused. Click `native_decide` for the
reason:

```lean +error +panel
example  : (mergeSort (List.range 1000).reverse).time = 5000 := by
  native_decide
```

:::notes
36:00. These use `native_decide`, which compiles and runs the code, so they trust Lean's compiler as well as its kernel. Plain `decide` would stay in the kernel, but cannot evaluate merge sort, which is defined by well-founded recursion.
:::
