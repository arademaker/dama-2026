/- s2n-bignum in Lean: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "s2n-bignum in Lean" =>

%%%
vertical := true
%%%

- [*Amazon's s2n-bignum*](https://github.com/awslabs/s2n-bignum): integer
  arithmetic routines for cryptography, in x86-64 and AArch64 machine code.
  Correctness and constant-time execution are verified in HOL Light, with a
  purpose-built relational Hoare logic.
- [*cslib-community/bignum*](https://github.com/cslib-community/bignum): a
  faithful port of that logic to Lean 4, including its lenses (*components*).
  The aim: verify other critical machine code in Lean, possibly with
  AI-assisted proofs.
- Two of s2n-bignum's ten ARM tutorials (`simple`, `sequence`) already run in
  Lean, on the first model, while the architecture is being rewritten.

:::attr («class» := "credits")
bignum: Guilherme Lima ([@gflima](https://github.com/gflima)),
Alexandre Rademaker ([@arademaker](https://github.com/arademaker)).
:::

:::notes
44:05. Quoted with `leanLibCode` from the pinned bignum: the build fails if a
quotation drifts from the source. Guilherme Lima moved the first model to
`Bignum.ArmOld` on 2026-09-26 and is rewriting it after HOL Light's
`Library/components.ml` and the relational Hoare algebra of s2n-bignum
(arXiv:2505.14348). The relational layer has started (`seq`, `⊑`, `≔`); the
Hoare triples (`ensures`) come next. A `Component α β` is a pair `read : α → β`,
`write : β → α → α` (`Bignum/Component/Basic.lean`). The ported tutorials are
`Bignum/ArmOld/Tutorial/{Simple,Sequence}.lean`, after
`s2n-bignum/arm/tutorial/{simple,sequence}.ml`. Components are where frame reasoning
lives: writing one register leaves the others alone. Today bignum does not
import CSLib; what it needs from CSLib (a RAM model, frame reasoning,
separating conjunction, byte-sequence theory) is what makes it a good stress
test for CSLib's foundations. Bullets follow Guilherme's own description.
:::

# ...components are lenses

A component is a lens on one part of the machine state: a way to read it and
a way to write it.

```leanLibCode Bignum.Component.Basic (startLine := 23) (endLine := 27) -stretch
structure Component (α : Type u₁) (β : Type u₂) where
  /-- Reader function. -/
  read : α → β
  /-- Writer function. -/
  write : β → α → α
```

`XREG n` is register `n`: `(XREG n).read s` reads it in state `s`, and
`(XREG n).write 0xabc s` returns `s` with `0xabc` in register `n`.

```leanLibCode Bignum.Arm.Instruction (startLine := 123) (endLine := 125) -stretch
/-- Main integer registers. -/
def XREG (n : Nat) : Component State (BitVec 64) :=
  if n ≥ 31 then XZR else registers :> .element n
```

:::notes
Optional. Guilherme's reading: `XREG n` is the component for register `n` of
the state; `.read s` reads it, `.write v s` returns the updated state.
:::

# ...and instructions are generic

```leanLibCode Bignum.Arm.Instruction (startLine := 562) (endLine := 570) -stretch
def ADD {α : Type u} {w : Nat}
    (Rd : Component α (BitVec w))
    (Rm : Component α (BitVec w))
    (Rn : Component α (BitVec w))
    (s : α) : α → Prop :=
  let m := Rm.read s
  let n := Rn.read s
  let d : BitVec w := m + n
  (Rd ≔ d) s
```

`Rd`, `Rm` and `Rn` are components passed as arguments, not specific
registers. The same `ADD`, unchanged, gives:

- `ADD X0 X1 X2`: 64-bit registers
- `ADD W0 W1 W2`: 32-bit registers
- `ADD X0 (X1.shifted LSL 1) (.rvalue 0x33)`: a shifted register and a literal

No separate version for shifts, literals or 32 bits; the same holds for most
other instructions.

:::notes
Optional. From Guilherme, including the three uses: there is no custom `ADD` per kind of argument;
`XREG`, `WREG`, `DREG`, and their compositions with shifts all go through the
same definition. `(Rd ≔ d)` is the relational assignment from
`Bignum.Relational`: the state after is the state before with `Rd` set to `d`.
:::
