/- The semantic spine: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "The semantic spine" =>

%%%
vertical := true
%%%

The most reused abstraction in the library: a labelled transition system is
*just* a ternary relation.

```leanLibCode Cslib.Foundations.Semantics.LTS.Basic (startLine := 64) (endLine := 66) -stretch
structure LTS (State : Type u) (Label : Type v) where
  /-- The transition relation. -/
  Tr : State → Label → State → Prop
```

A nondeterministic automaton is an LTS with start states:

```leanLibCode Cslib.Computability.Automata.NA.Basic (startLine := 39) (endLine := 41) -stretch
structure NA (State Symbol : Type*) extends LTS State Symbol where
  /-- The set of initial states of the automaton. -/
  start : Set State
```

Nondeterministic Turing machines `SingleTapeNTM` extends `NA`, with tape actions
(`read`, `write`, `move`) as labels.

:::attr («class» := "credits")
CSLib authors: Fabrizio Montesi ([@fmontesi](https://github.com/fmontesi)),
Thomas Waring ([@thomaskwaring](https://github.com/thomaskwaring)),
Ching-Tsun Chou ([@ctchou](https://github.com/ctchou)),
Chris Henson ([@chenson2018](https://github.com/chenson2018))
:::

:::notes
14:00. CCS declares its transition relation with `@[lts lts]`
(`Cslib/Languages/CCS/Semantics.lean`); Stateful Processes, another process
calculus in CSLib, does the same. `SingleTapeNTM` is in
`Cslib/Computability/Machines/Turing/SingleTape/NonDeterministic.lean`, after
Sipser. The design point: keep LTS thin, so everything can be parametrised over it.
:::


# A tiny nondeterministic automaton

```diagram (background := "#ffffff")
open Illuminate in
let ink := rgb!"#2F1A0F"
let label (t : String) : Diagram SVG :=
  Diagram.text t { fontSize := 18, fontFamily := "text" }
let q0 : Diagram SVG := Diagram.atop (label "q₀")
  (Diagram.circle 26 (fill := rgb!"#ffffff") (stroke := { width := 2, color := ink }) (name := some `q0))
let q1 : Diagram SVG := Diagram.atop (label "q₁") <| Diagram.atop
  (Diagram.circle 21 (fill := rgb!"#E5D0BA") (stroke := { width := 2, color := ink }))
  (Diagram.circle 27 (fill := rgb!"#E5D0BA") (stroke := { width := 2, color := ink }) (name := some `q1))
let arrow : Stroke := { width := 2, color := ink }
let head : Option Arrowhead := some { type := .latex }
Diagram.hsep 140 [q0, q1]
|>.connect { point := `q0.west, shift := ⟨-60, 0⟩ } { point := `q0.west, arrowhead := head } (stroke := arrow)
|>.connect `q0.east { point := `q1.west, arrowhead := head } (stroke := arrow)
    (label := some { label := label "a", shift := ⟨0, 14⟩, upright := true })
|>.connect { point := `q0.north, shift := ⟨-14, -4⟩, angle := some 2.1, pull := 1.6 }
    { point := `q0.north, shift := ⟨14, -4⟩, angle := some (-2.1), pull := 1.6, arrowhead := head }
    (stroke := arrow) (label := some { label := label "a, b", shift := ⟨0, 8⟩, upright := true })
|>.scale 0.8
```

An `NA.FinAcc` is an `NA` (an LTS with start states) plus a set of *accepting*
states. Its instance of `Acceptor` says when a word is accepted: a multistep
transition (`MTr`) labelled by the word leads from a start state to an
accepting state.

```leanLibCode Cslib.Computability.Automata.NA.Basic (startLine := 64) (endLine := 66) -stretch
instance : Acceptor (FinAcc State Symbol) Symbol where
  Accepts (a : FinAcc State Symbol) (xs : List Symbol) :=
    ∃ s ∈ a.start, ∃ s' ∈ a.accept, a.MTr s xs s'
```

`language a` is the set of words that `a` accepts.

:::notes
15:15.
:::

# ...in Lean

Words over `{a, b}` that end in `a`. On `a`, state `q₀` may stay or move to
`q₁`:

```lean -stretch
/- !hide -/
namespace NFA
open Cslib Cslib.Automata Acceptor
/- !end hide -/
inductive St | q₀ | q₁

def endsInA : NA.FinAcc St Char where
  Tr s c s' := (s = .q₀ ∧ s' = .q₀) ∨ (s = .q₀ ∧ c = 'a' ∧ s' = .q₁)
  start := {.q₀}
  accept := {.q₁}

example : ['b', 'a'] ∈ language endsInA :=
  ⟨.q₀, rfl, .q₁, rfl,
    .stepL (.inl ⟨rfl, rfl⟩) (.stepL (.inr ⟨rfl, rfl, rfl⟩) .refl)⟩

example : ['a', 'b'] ∉ language endsInA := by
  rintro ⟨_, rfl, _, rfl, h⟩
  cases h with | stepL _ h =>
  cases h with | stepL h r => cases r; simp [endsInA] at h
/- !hide -/
end NFA
/- !end hide -/
```

:::notes
16:30.
:::


# Bisimulation, defined once

```leanLibCode Cslib.Foundations.Semantics.LTS.Bisimulation (startLine := 77) (endLine := 83) -stretch
def IsBisimulation (lts₁ : LTS State₁ Label) (lts₂ : LTS State₂ Label)
    (r : State₁ → State₂ → Prop) : Prop :=
  ∀ ⦃s₁ s₂⦄, r s₁ s₂ → ∀ μ, (
    (∀ s₁', lts₁.Tr s₁ μ s₁' → ∃ s₂', lts₂.Tr s₂ μ s₂' ∧ r s₁' s₂')
    ∧
    (∀ s₂', lts₂.Tr s₂ μ s₂' → ∃ s₁', lts₁.Tr s₁ μ s₁' ∧ r s₁' s₂')
  )
```

Two states are bisimilar, `s₁ ~[lts₁, lts₂] s₂`, when *some* bisimulation
relates them.

:::notes
17:30.
:::

# Bisimulation, constructively

Two clocks: one state ticking forever, and two states ticking back and forth.
To prove them bisimilar, exhibit a relation, here everything to everything,
and check the transfer condition:

```lean -stretch
/- !hide -/
namespace Clock
open Cslib Cslib.LTS
open scoped Cslib.LTS
/- !end hide -/
inductive C₁ | t₀
inductive C₂ | t₁ | t₂

def one : LTS C₁ Unit := ⟨fun _ _ _ => True⟩
def two : LTS C₂ Unit := ⟨fun s _ s' => s ≠ s'⟩

example : C₁.t₀ ~[one, two] C₂.t₁ := by
  refine ⟨fun _ _ => True, trivial, ?_⟩
  intro _ s₂ _ _
  refine ⟨fun _ _ => ?_, fun _ _ => ⟨.t₀, trivial, trivial⟩⟩
  cases s₂
  · exact ⟨.t₂, by simp [two], trivial⟩
  · exact ⟨.t₁, by simp [two], trivial⟩
/- !hide -/
end Clock
/- !end hide -/
```

:::notes
18:30. The constructive side of bisimulation: coinduction is "show me an r". The
vending machines next are the other side: no r exists, and HML proves it.
:::
