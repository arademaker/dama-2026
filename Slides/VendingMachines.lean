/- Two vending machines: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "Two vending machines" =>

%%%
vertical := true
%%%

Milner, _Communication and Concurrency_ (1989).

- *Good:* coin, then _you_ pick tea or coffee.
  $$`
  \mathit{Good} \stackrel{\text{def}}{=} \mathit{coin}.(\mathit{tea}.\mathit{Good} + \mathit{coffee}.\mathit{Good})`
- *Bad:* coin, then _the machine_ picks.
  $$`
  \mathit{Bad} \stackrel{\text{def}}{=} \mathit{coin}.\mathit{tea}.\mathit{Bad} + \mathit{coin}.\mathit{coffee}.\mathit{Bad}`

Their logs are identical: `coin tea`, `coin coffee`, ... Same *traces*. A trace-based test cannot tell them apart.

After the coin, the bad machine may already have chosen coffee, and then the tea button does nothing. A trace records the actions that happened; it never records an action that was refused.

:::attr («class» := "credits")
Example: Jesse Alama ([@jessealama](https://github.com/jessealama)). CSLib authors: Fabrizio Montesi ([@fmontesi](https://github.com/fmontesi)).
:::

:::notes
19:30. No Lean on this slide on purpose. The audience is not assumed to know
process calculi. The one thing to land: same observable logs, different
behaviour. In the bad machine the choice happens at the coin, before the
customer can press anything, so no amount of trace-based testing can see it.
If asked: De Nicola and Hennessy's must-testing does tell them apart, precisely
because it observes refusals.
:::

# Traces are too coarse

Trace equivalence ignores which actions are available at each step.

*Bisimilarity* (slide 14.4): every move of one machine must be matched by a move of the other, and the states reached must again be related, at every step.

Two ways to prove that our machines are *not* bisimilar:

1. *Directly*, as CSLib's own `vm_ltsD_ltsND_not_bisim` does: assume a bisimulation and follow the transitions until it breaks.
2. *With a logic:* find a formula that one machine satisfies and the other does not.

:::notes
20:45. Milner's point: traces are the wrong equivalence for interacting systems.
Next: the machines in CSLib's CCS, the CCS semantics, then both proofs.
:::

# ...in CSLib's CCS

```lean -stretch
/- !hide -/
open Cslib Cslib.CCS Process
/- !end hide -/
abbrev coin := Act.name "coin"
abbrev tea := Act.name "tea"
abbrev coffee := Act.name "coffee"

inductive Machine | good | bad

/-- good = coin.(tea + coffee)     bad = coin.tea + coin.coffee -/
@[grind =]
def defs : Machine → Option (Process String Machine)
  | .good => some `(CCS| coin. ((tea. const .good) + (coffee. const .good)))
  | .bad  => some `(CCS| (coin. tea. const .bad) + (coin. coffee. const .bad))

/-- Both machines live in one transition system: CCS's, from CSLib. -/
abbrev machines := CCS.lts (defs := defs)
```

One LTS, `machines`, with two constants: the good machine is `const .good`,
the bad one `const .bad`.

:::notes
21:45. CCS is a modelling language for concurrent systems. CSLib provides its syntax and operational semantics as a library object, a labelled transition system, that the rest of the library knows how to talk about. Traces are blind to refusals: a trace records what happened, never what was offered and declined.
:::

# ...and its semantics

The transitions of a CCS process are an inductive relation, one rule per
construct. CSLib declares it as an LTS with `@[lts lts]`:

```leanLibCode Cslib.Languages.CCS.Semantics (startLine := 34) (endLine := 44) -stretch
@[lts lts]
inductive Tr : Process Name Constant → Act Name → Process Name Constant → Prop where
  | pre : Tr (pre μ p) μ p
  | parL : Tr p μ p' → Tr (par p q) μ (par p' q)
  | parR : Tr q μ q' → Tr (par p q) μ (par p q')
  | com :
    μ.Co μ' → Tr p μ p' → Tr q μ' q' → Tr (par p q) Act.τ (par p' q')
  | choiceL : Tr p μ p' → Tr (choice p q) μ p'
  | choiceR : Tr q μ q' → Tr (choice p q) μ q'
  | res : μ ≠ Act.name a → μ ≠ Act.coname a → Tr p μ p' → Tr (res a p) μ (res a p')
  | const : defs k = some p → Tr p μ p' → Tr (const k) μ p'
```

Our machines need four rules: `pre`, `choiceL`, `choiceR`, and `const`, which
unfolds a constant through `defs`.

:::notes
22:45. Direct formalisation of the rules in Sangiorgi's textbook.
:::

# ...as transition graphs

```diagram (background := "#ffffff")
open Illuminate in
let ink := rgb!"#2F1A0F"
let txt (t : String) : Diagram SVG := Diagram.text t { fontSize := 15, fontFamily := "text" }
let st (n : Lean.Name) (t : String) (w : Float) : Diagram SVG :=
  Diagram.atop (txt t) (Diagram.roundedRect w 34 8 (fill := rgb!"#ffffff")
    (stroke := { width := 1.8, color := ink }) (name := some n))
let s : Stroke := { width := 1.8, color := ink }
let h : Option Arrowhead := some { type := .latex }
let lbl (t : String) (dy : Float) : Option (Label SVG) :=
  some { label := txt t, shift := ⟨0, dy⟩, upright := true }
let good := Diagram.hsep 110 [st `g "Good" 70, st `p "tea.Good + coffee.Good" 200]
  |>.connect `g.east { point := `p.west, arrowhead := h } (stroke := s) (label := lbl "coin" 12)
  |>.connect { point := `p.north, angle := some 2.4, pull := 0.3 }
      { point := `g.north, angle := some (-2.4), pull := 0.3, arrowhead := h } (stroke := s) (label := lbl "tea" 12)
  |>.connect { point := `p.south, angle := some (-2.4), pull := 0.3 }
      { point := `g.south, angle := some 2.4, pull := 0.3, arrowhead := h } (stroke := s) (label := lbl "coffee" (-12))
let bad := Diagram.hsep 90 [st `t "tea.Bad" 90, st `b "Bad" 70, st `c "coffee.Bad" 110]
  |>.connect `b.west { point := `t.east, arrowhead := h } (stroke := s) (label := lbl "coin" 36)
  |>.connect `b.east { point := `c.west, arrowhead := h } (stroke := s) (label := lbl "coin" 12)
  |>.connect { point := `t.south, angle := some (-0.7), pull := 0.4 }
      { point := `b.south, angle := some 0.7, pull := 0.4, arrowhead := h } (stroke := s) (label := lbl "tea" (-12))
  |>.connect { point := `c.south, angle := some (-2.44), pull := 0.4 }
      { point := `b.south, angle := some 2.44, pull := 0.4, arrowhead := h } (stroke := s) (label := lbl "coffee" (-12))
Diagram.vsep 40 [good, bad] |>.scale 0.65
```

Both have the traces `coin tea`, `coin coffee`, ... After `coin`, *Good*
still offers both drinks; *Bad* has already committed to one.

:::notes
23:45. This is the LTS that `machines` denotes, drawn: each box is a process term,
each arrow a CCS transition derived with the rules on the previous slide.
:::

# ...not bisimilar, directly

Assume a bisimulation `r`. After `coin`, the good machine has a single
successor, so `r` must relate `tea.Good + coffee.Good` with `tea.Bad`. Only the
first can do `coffee`:

```lean -stretch
/- !hide -/
open LTS LTS.IsBisimulation LTS.Bisimilarity in
/- !end hide -/
theorem good_not_bisim_bad_direct :
    ¬ ((«const» Machine.good) ~[machines] («const» Machine.bad)) := by
  rintro ⟨r, hr, hb⟩
  let p₁ := `(CCS| (tea. const Machine.good) + (coffee. const Machine.good))
  let q₁ := `(CCS| tea. const Machine.bad)
  have hdet : machines.DeterministicStateLabel («const» .good) coin := by
    intro _ _ h₁ h₂
    grind [const_tr h₁, const_tr h₂]
  have h : r p₁ q₁ :=
    match_deterministic hb hr hdet
      (.const rfl .pre) (.const rfl (.choiceL .pre))
  have hpq : p₁ ~[machines] q₁ := ⟨r, h, hb⟩
  have hc : machines.Tr p₁ coffee («const» .good) := .choiceR .pre
  grind [hpq.follow_fst]
```

:::notes
24:30. Adapted from CSLib's own `vm_ltsD_ltsND_not_bisim`
(`Cslib/Algorithms/CCS/VendingMachine.lean`), which encodes the example
differently: one constant `vm` and two definition functions, `vendingDefs`
(deterministic, the good machine) and `vendingDefsND` (the bad one), hence two
LTSs `ltsD` and `ltsND`. The deck keeps both machines in one LTS because the
HML lemma used later works within a single model. `match_deterministic`: if a
state has a unique `coin` successor, a bisimulation must relate it to every
`coin` successor of the other side.
:::

# Hennessy–Milner logic

A modal logic for labelled transition systems. Its formulas describe which
actions a state can perform, and what holds after them:

$$`\begin{aligned}
s \models \langle a\rangle\,\varphi &\iff \exists s'.\; s \xrightarrow{a} s' \text{ and } s' \models \varphi
  && \text{some } a \text{ is possible, then } \varphi \\
s \models [a]\,\varphi &\iff \forall s'.\; s \xrightarrow{a} s' \text{ implies } s' \models \varphi
  && \text{after every } a,\ \varphi
\end{aligned}`

plus `⊤`, `¬` and `∧`.

*Hennessy–Milner theorem (1985):*
- Bisimilar states satisfy the same formulas.
- For image-finite systems, the converse holds: states that are not bisimilar
  are always told apart by some formula.

The first direction is the one we use, as CSLib's `bisimulation_satisfies`:

```leanLibCode Cslib.Logics.HML.Basic (startLine := 170) (endLine := 172) -stretch
lemma bisimulation_satisfies {hrb : m.lts.IsHomBisimulation r}
    (hv : ∀ {s1 s2}, r s1 s2 → ∀ p, m.v s1 p ↔ m.v s2 p) (hr : r s1 s2)
    (φ : HML.Proposition Label Atom) : ⇓HML[m,s1 ⊨ φ] ↔ ⇓HML[m,s2 ⊨ φ] := by
```

:::attr («class» := "credits")
CSLib authors: Fabrizio Montesi ([@fmontesi](https://github.com/fmontesi)), Marco Peressotti ([@mperessotti](https://github.com/mperessotti)), Alexandre Rademaker ([@arademaker](https://github.com/arademaker)).
:::

:::notes
25:45. CSLib's HML is an instance of its general modal logic; `[a]` is defined as `¬⟨a⟩¬`.
The full characterisation, both directions, is `theoryEq_eq_bisimilarity`
in the same file; it needs image-finiteness only for the converse. The
converse is what makes the method complete: a distinguishing formula always
exists. In our example we wrote the formula by hand.
:::

# ...one formula, in CSLib's HML

In CSLib, formulas are evaluated in a model, an LTS plus a valuation of atomic
propositions (`Cslib/Logics/HML/Basic.lean`):

```leanLibCode Cslib.Logics.HML.Basic (startLine := 61) (endLine := 65) -stretch
structure Model State Label Atom where
  /-- The labelled transition system. -/
  lts : LTS State Label
  /-- Valuation of atoms at states. -/
  v : State → Atom → Prop
```

Our model `m` is the CCS LTS of both machines with no atomic propositions
(`Atom := Empty`), so only transitions matter. The formula
`[coin] ⟨tea⟩ ⊤`: after every `coin`, `tea` is possible.

```lean -stretch
/- !hide -/
open Cslib.Logic.Modal HML
open scoped Cslib.Logic Cslib.Logic.Modal.Proposition
  Cslib.Logic.InferenceSystem Cslib.CCS Cslib.Logic.Modal.HML
/- !end hide -/
/-- No atomic propositions: only the transitions matter. -/
abbrev m : HML.Model (Process String Machine) (Act String) Empty :=
  ⟨machines, fun _ _ => False⟩

/-- "After every coin, tea is on offer." -/
def teaAfterCoin : HML.Proposition (Act String) Empty := d[coin] (d⟨tea⟩ ⊤)
```

:::notes
27:00. Box means "after every coin"; diamond means "tea is possible". HML is
an instance of CSLib's general modal logic, evaluated on the CCS semantics.
The proof uses CSLib's inversion lemmas for CCS transitions.
:::

# ...which the good machine accepts and the bad machine fails

```lean -stretch
theorem good_ok : ⇓HML[m, «const» Machine.good ⊨ teaAfterCoin] := by
  rw [teaAfterCoin, Satisfies.hml_dynBox_iff_forall]
  rintro s' htr
  obtain ⟨_, ⟨⟩, ⟨⟩⟩ := const_tr htr
  exact Satisfies.hml_dynDiamond_intro (Tr.choiceL Tr.pre) (by grind [modal])

theorem bad_fails : ¬ ⇓HML[m, «const» Machine.bad ⊨ teaAfterCoin] := by
  rw [teaAfterCoin, Satisfies.hml_dynBox_iff_forall]
  intro h
  have := h (pre coffee («const» .bad)) (Tr.const rfl (Tr.choiceR Tr.pre))
  obtain ⟨_, htr, -⟩ := Satisfies.hml_dynDiamond_iff_exists.mp this
  grind
```

In `obtain ⟨_, ⟨⟩, ⟨⟩⟩`, each `⟨⟩` case-splits a hypothesis and substitutes
it away: after one coin, the good machine has a single successor, and the goal
is now about that successor.

:::notes
28:00. The bad machine has a coin transition after which tea is impossible, and that
transition is the witness passed to the box in the `have`.
:::

# ...and a theorem

```lean -stretch
/- !hide -/
open scoped Cslib.LTS
/- !end hide -/
theorem good_not_bisim_bad :
    ¬ ((«const» Machine.good) ~[machines] («const» Machine.bad)) := by
  rintro ⟨r, hr, hb⟩
  grind [bisimulation_satisfies (m := m) (hrb := hb) (by simp) hr teaAfterCoin,
    good_ok, bad_fails]
```

So a formula true for one machine and false for the other is a certificate that they are not bisimilar.

:::notes
29:15. CSLib proves that bisimilar states satisfy the same HML formulas
(`bisimulation_satisfies`). So one separating formula gives non-bisimilarity:
unpack the bisimulation and apply the lemma.
:::

# Three parts of CSLib in 35 lines

- A *language*: CCS, with its operational semantics.
- A *logic*: HML, evaluated on that semantics.
- The *semantic infrastructure* that connects them: transition systems,
  bisimulation, the Hennessy–Milner theorem.

Languages produce transition systems. Logics consume them. Metatheory is
proved once.

:::notes
30:00. CSLib also proves that bisimilarity is a congruence for CCS
(`bisimilarity_is_congruence`): equivalent components stay equivalent inside
any context. Mention if asked about compositional reasoning.
The point for this audience is the design. This is what lets an
AI-written model of a protocol be checked against a spec written in a logic,
without bespoke glue.
:::
