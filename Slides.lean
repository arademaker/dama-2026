/-
Slides for the Foundations of AI Seminar Series, Georgia Tech,
Monday 2026-10-05, 3-4pm ET (Klaus 2456 + Zoom). One hour with Q&A, so the
deck is paced for about 50 minutes; the speaker notes carry a running clock.

Built from three sources:
  * the `alexandre/generated-draft` framing (Parts 1, 3, 4),
  * Jesse Alama's two worked examples (Part 2), with the HML proofs ported to
    the `Cslib.Logic.Modal` API,
  * the "checker says no" beat from
    `jesse/examples-and-deck`.

Speaker notes ship inside the generated `index.html`: treat them as public.
No Initiative financials anywhere in this file.
-/
module

public import VersoSlides
-- The deck's top-level slides that have Lean code or vertical sub-slides live
-- in `Slides/`, one per file, and are included below with `{include 1 …}`.
-- Editing a slide in this file re-elaborates only this file; editing one in
-- `Slides/` rebuilds that file and this one.
public import Slides.LeanGame
public import Slides.WhereItStands
public import Slides.Governance
public import Slides.Contributing
public import Slides.SemanticSpine
public import Slides.VendingMachines
public import Slides.Sorting
public import Slides.FAD
public import Slides.Bignum

open VersoSlides

#doc (Slides) "CSLib: The Lean Computer Science Library" =>

# CSLib: The Lean Computer Science Library

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

Alexandre Rademaker

CSLib Initiative, Renphil | FGV/EMAp

Foundations of AI Seminar Series, Georgia Tech | October 5, 2026

[arademaker.github.io/gatech-2026](https://arademaker.github.io/gatech-2026/)

# About me

- *MSc in CS* (UFF, 2005): formal methods, rewriting logic in
  [Maude](https://maude.cs.illinois.edu).
- *PhD in CS* (PUC-Rio, 2010): proof theory for description logics.
  Internships at [SRI](https://www.csl.sri.com/~shankar/) (PVS, 2009) and
  Microsoft Research, with the [Z3](https://github.com/Z3Prover/z3) team (2008).
- *IBM Research Brazil* (2012–2025): NLP, computational semantics, ontologies.
- *FGV/EMAp*, professor since 2010: discrete mathematics, programming,
  algorithms, type theory, category theory.
- In the Lean community since March 2015.

:::notes
0:00. Thank the organisers. One hour including questions: aim to finish the
last slide at 50:00, leaving about 10 minutes for questions. Keep this slide
short: the thread is logic and formal methods, then language and knowledge
representation, now back to proofs with Lean.
:::

# What this talk is about

- *The library.* What CSLib is, where it stands, how it is governed, how to
  contribute.
- *The API, concretely.* Two worked examples, type-checked against CSLib
  while this deck was built.
- *The Initiative.* What Renaissance Philanthropy supports, and why that is
  not the same thing as the library.
- *The ecosystem, and AI.* Textbooks, courses and verification projects built
  on CSLib; CSLib as data for AI, and AI as a CSLib contributor.

:::notes
0:45. Every `lean` block in the middle third elaborates against a pinned CSLib
revision; the outputs on screen were computed by Lean at build time.
:::

# What is Lean?

{image "static/images/lean-logo.png" (width := "18%")}[Lean logo]

[lean-lang.org](https://lean-lang.org): _a proof assistant and programming language that is
transforming how we approach mathematics, software verification, and AI._

Lean provides *machine-checkable proofs*.

Lean addresses the *trust bottleneck*.

Lean is implemented in Lean, and is *very extensible* and *scalable*.

It is based on dependent type theory.

Small *trusted* kernel. Proofs can be exported and independently checked.

*325,000+* unique installations: [VS Code](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4) (184K) + [Open VSX](https://open-vsx.org/extension/leanprover/lean4) (141K).

:::attr («class» := "credits")
This and the next two slides are adapted from the FROCON 2026 deck of Leo de Moura ([@leodemoura](https://github.com/leodemoura)).
:::

:::notes
1:30. Adapted from Leo de Moura's FROCON 2026 deck. The audience may not know
Lean: one minute on what it is, one on what using it feels like, then Mathlib,
which later slides keep referring to.
:::

{include 1 Slides.LeanGame}

# Mathlib: The Lean Mathematical Library

Created in July 2017, in Lean 3 during [Big Proof](https://www.newton.ac.uk/event/bpr/). An open-source, community-driven library. *Today*:

:::hstack
- *280,000+* formalized theorems.
- *2.4M+* lines of Lean. *50,000+* lines of extensions.
- *750+* contributors.
- *1,500+* type classes, *20,000+* instances.
- [github.com/leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4)

{image "static/images/mathlib-deps.png" (width := "100%")}[Mathlib dependency graph]
:::

:::notes
3:00. Figures from Leo's FROCON 2026 deck. Mathlib is the model CSLib follows:
one shared library, community review, and everything else depends on it.
CSLib itself depends on Mathlib.
:::

# Why a library, and why now

- AI writes more and more of the world's code. Tests sample inputs; a proof covers all of them.
- But a proof needs a *statement*, and a statement needs vocabulary: transition systems, logics, semantics, cost models.
- CSLib's aim: that vocabulary for computer science, shared, and checked by Lean's kernel.


> AI-based provers are bottlenecked by the abstractions available in the
  underlying proof assistant.

  — Barrett et al., CSLib: Towards a Lean Computer Science Library, CACM
  (forthcoming)


:::notes
3:30. Quote from the CACM article (Barrett et al.). This replaces the usual
"AI wrote a verified codec" opening: the audience should meet CSLib first.
lean-zip comes back in Part 3, where it belongs.
:::

# Part 1: The Library

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
5:00.
:::


# What is CSLib?

> An open-source library of reusable components for proving theorems in computer science and writing formally verified code in the Lean programming language and proof assistant.

Two pillars:

1. *Formalizing computer science in Lean.* Models of computation, semantics, logics, algorithms and data structures with correctness *and* complexity proofs.
2. *Reasoning about everyday code.* Boole, an intermediate verification language embedded in Lean, as the bridge from mainstream imperative code to CSLib's machinery.

[github.com/leanprover/cslib](https://github.com/leanprover/cslib) ·
[cslib.io](https://www.cslib.io/)

:::notes
5:10. Pillar 2 is the most ambitious bet, and it is still early: most of today's code is
Pillar 1.
:::


# Why a unified library?

Formal-methods work tends to produce *isolated artifacts*: a semantics here, a memory model there, a process calculus somewhere else.

> The formalizations are designed to form a coherent and integrated framework
  rather than a collection of unrelated modules.

  — Barrett et al., CSLib: Towards a Lean Computer Science Library, CACM
  (forthcoming)

Mathlib is a dependency:

- CSLib reuses its mathematics, style guide and linters, and many definitions.
- The rule: do not rebuild what Mathlib already has.
- The boundary is not always obvious. Mathlib also has [DFA](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Computability/DFA.html), [context-free grammars](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Computability/ContextFreeGrammar.html) and [graphs](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Combinatorics/Graph/Basic.html), `RegularExpressions`, etc; all of them, computer science concepts.

:::notes
6:25. "Unified" is the paper's word ("a unified body of formalizations").
"Without a library like this, every researcher has to rebuild all the
foundations before they can even begin" (Renaissance Philanthropy Q&A).
Examples of the boundary: Mathlib's `ContextFreeGrammar` and its new `Graph`
(Mathlib.Combinatorics.Graph.Basic), next to CSLib's own automata built on
LTS; where graph definitions should live was a long #CSLib Zulip thread
("New graph definitions"). CSLib imports Mathlib's `Language`,
`RegularExpressions`, `DFA` and `TuringMachine.Tape`.
:::


# How it started

Some independent efforts converged around July, 2025, bringing together
Clark Barrett, Swarat Chaudhuri, Jim Grundy (Amazon), Pushmeet Kohli, Fabrizio
Montesi and Leonardo de Moura:

- Clark Barrett and Swarat Chaudhuri were discussing shared infrastructure
  for formal computer science.
- Pushmeet Kohli had raised the same idea with Leonardo de Moura (Kevin
  Hartnett, [_The Proof in the Code_](https://www.quantabooks.org/books/the-proof-in-the-code/), 2026).
- Fabrizio Montesi had independently started a `cslib` repository.
- Amazon and Google DeepMind funded two technical-lead positions.
- Renaissance Philanthropy came in to build the Initiative around it.

Supporting organisations listed on [cslib.io](https://cslib.io): Amazon, Google DeepMind, FORM, Renaissance Philanthropy, Stanford Center for Automated Reasoning.

:::notes
7:40. Source: the Renaissance Philanthropy Q&A (August 2026). The repository's
first commit is 2025-06-17; the technical leads started in August 2025.
The Kohli–de Moura conversation is from Hartnett's book (Quanta Books, June
2026). Montesi's Lean Together 2026 slides ("A convergence of ambitions in
2025") list Barrett, Chaudhuri, Jim Grundy, Kohli, Montesi and de Moura.
:::

{include 1 Slides.WhereItStands}

{include 1 Slides.Governance}

# CSLib at FLoC 2026

Two papers, two complementary views of the same library:

- *Computer Science as Infrastructure: the Spine of CSLib.* Christopher
  Henson and Fabrizio Montesi. Founding technical principles, reusable
  semantic interfaces (reduction and labelled transition systems), proof
  automation, CI for Mathlib compatibility.
  [arXiv:2602.15078](https://arxiv.org/abs/2602.15078)
- *CSLib: The Lean Computer Science Library.* Presented by Clark Barrett and
  Sorrachai Yingchareonthawornchai; the vision paper of the steering
  committee and technical leads, forthcoming in CACM.
  [arXiv:2602.04846](https://arxiv.org/abs/2602.04846)

:::notes
11:25. Pointers for the theory-minded part of the audience. The first is the
"how it is built" paper; the second is the "why and where to" paper.
:::

{include 1 Slides.Contributing}

# Part 2: The API, Concretely

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

Every Lean block from here on is elaborated against CSLib at `12ba7cf`,
unless the slide says it is quoting.

:::notes
13:50.
:::

{include 1 Slides.SemanticSpine}

{include 1 Slides.VendingMachines}

{include 1 Slides.Sorting}

# Part 3: The CSLib Initiative

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
36:45.
:::

# Opensource Library ≠ Initiative

:::table +colHeaders +rowSeps
*
  * The library
  * The Initiative
*
  * `leanprover/cslib`, open source
  * A programme at Renaissance Philanthropy
*
  * Community-governed; mostly volunteers
  * A director and a small team
*
  * Decides its own technical direction
  * Helps CSLib growth; does not lead it
*
  * Grows organically
  * Invests where growth *won't* happen on its own
:::

Modelled on the Mathlib Initiative: a thriving open-source project, paired
with a dedicated team for work that is hard to sustain on volunteer effort.

:::notes
36:55. Renaissance Philanthropy supplies the organisational infrastructure:
HR, legal, finance. The Initiative does not own the library.
:::

# The Initiative's four goals

:::table +colHeaders +rowSeps
*
  * Goal
  * What it means
*
  * *G1*: Sustain organic growth
  * Review workflow, CI and DevOps, documentation
*
  * *G2*: Demonstrate value
  * Pulling projects; an open AI dataset
*
  * *G3*: Focused technical investment
  * Boole, semantics, specification logics, RAM model ...
*
  * *G4*: Support community efforts
  * Software Foundations in Lean, Separation Logic, Signal Shot (BAIF, Crypto)
:::

:::notes
37:55. The diagnosis behind G1: CSLib's problem is not lack of interest.
Contributors are joining and PRs are flowing; the risk is lack of structure.
G3 is where dedicated effort goes: areas that will not mature through
volunteer work alone. G4 is coordination, not ownership.
:::

# Pulling projects

The most important idea in the plan:

> External formalisation efforts that *demand new CSLib primitives* and
  *upstream their general results back*.

- They aim at software the world uses every day.
- Their requirements decide what CSLib builds next.
- The general pieces they produce come back to the library.

:::fragment
The test they impose: general lemmas must be *separable from project code*.
If that is hard, the API is wrong.
:::

:::notes
39:10. "CSLib is never the end goal but a shared foundation that grows
stronger with each one." lean-zip, next slide, is the example we use today.
:::

# Learning from lean-zip

[lean-zip](https://github.com/kim-em/lean-zip) (Kim Morrison): DEFLATE in pure
Lean, with a kernel-checked theorem that decompression inverts compression,
for every input and every level. About 1,100 theorems, no `sorry`.

- *Written by AI agents, loosely supervised.* Agents claimed issues, worked
  in their own git worktrees, and opened pull requests.
- *The proof is the gate.* A PR could not merge unless the round-trip proof
  still went through.
- *So optimisation is safe to automate.* It ended up faster than Rust's
  `miniz_oxide` at the same compression ratio.

:::fragment
For the Initiative: learn from this way of building verified software, and
upstream to CSLib whatever is general.
:::

:::notes
40:10. A new way of doing software verification, not just a verified codec.
Facts from the lean-zip README (2026-09): about 32k lines of proof; at level
6, about 30% faster than `miniz_oxide` at equal ratio. The full history,
including the agents' plans and per-session logs, is kept at the `pre-split`
tag. Kim's own words, from "Why Lean is faster than Rust" (July 2026): the
library is proved correct, which "allows us to let AIs loose optimizing the
code, requiring that they update the proof whenever the implementation
materially changes". lean-zip does not depend on CSLib today.
:::

# Part 4: CSLib in the Wild

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
41:25.
:::

# Software Foundations in Lean

Benjamin Pierce (Penn), Michael Hicks (Penn and AWS) and Harry Goldstein (Buffalo) are adapting
[Software Foundations](https://github.com/plclub/sf-in-lean/) (also [here](https://sf-in-lean.torus.icu)), the standard introduction to interactive theorem proving, to Lean.

- Courses that draw on CSLib and contribute back to it.
- A pipeline from students to library contributors.
- A planned follow-up course on *agentic proof engineering*.

:::fragment
Teaching is the maturity test that matters most: it forces the API to be
explainable.
:::

:::notes
41:35. updated. links to the repo
:::

{include 1 Slides.FAD}

# A course book in progress: CSwL

[Computational Semantics with Lean](https://emap-nlp.github.io/book/)
([repo](https://github.com/cslib-community/CSwL)) brings van Eijck and Unger's
[_Computational Semantics with Functional Programming_](https://staff.fnwi.uva.nl/d.j.n.vaneijck2/cs/)
from Haskell to Lean, while the FGV/EMAp course runs.

- *Now:* stay close to the book, the safe route while students follow it.
- *Next weeks:* reuse what is already mapped:
  [grammars](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Computability/ContextFreeGrammar.html),
  [propositional](https://api.cslib.io/docs/Cslib/Logics/Propositional/Defs.html)
  and [modal](https://api.cslib.io/docs/Cslib/Logics/Modal/Basic.html) logic,
  [LTS](https://api.cslib.io/docs/Cslib/Foundations/Semantics/LTS/Basic.html).
- *Then:* contribute what CSLib lacks: first-order logic,
  [feature structures](https://en.wikipedia.org/wiki/Feature_structure) and
  their unification.

With Software Foundations in Lean and FAD: CSLib as a base for teaching.

:::notes
43:20. A Verso book, like these slides. Grammars are Mathlib's
`ContextFreeGrammar`; the logics and LTS are CSLib's. The course runs
this semester, so the first pass follows the original closely; the mapping to
Mathlib and CSLib is done and lands chapter by chapter in the next weeks. Where
the library's shape differs from the book's (CSLib's `Satisfies`, for
instance), the book's presentation is the one that moves. First-order logic and
feature-structure unification go the other way: the book's needs become CSLib
pull requests.
:::

{include 1 Slides.Bignum}

# The community organisation

[github.com/cslib-community](https://github.com/cslib-community): *home for
community projects built with, around, and for CSLib.*

- *fad*: functional algorithm design.
- *CSwL*: computational semantics.
- *bignum*: s2n-bignum in Lean.
- *AlgoLib*: graph algorithms, flows, union–find, with correctness and
  running-time proofs.

Where projects live *before* anything is upstreamed.

:::notes
45:05. The org is the staging area for pulling projects: general results move
into `leanprover/cslib`, project-specific code stays here.
:::

# Part 5: CSLib for AI, and with AI

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
45:35.
:::

# For AI

> The ideal outcome would be a "flywheel" in which both AI and human experts
  become progressively more efficient at producing new knowledge.

  — Barrett et al., CSLib: Towards a Lean Computer Science Library, CACM
  (forthcoming)

- CSLib as *vocabulary*: definitions an AI can state specifications in.
- CSLib as *data*: a planned regular dataset of goal states, tactic traces
  and cost annotations, in Mathlib's format.
- The kernel as the gate: RL agents find every shortcut; the kernel is the
  one thing they cannot fake.

:::notes
45:45. Quote from the CACM article. The dataset is a G2 deliverable, format-
compatible with Mathlib's pipeline so labs can consume both.
:::

# With AI

- CSLib ships an `AGENTS.md`: build, lint and test instructions for coding
  agents.
- It follows Mathlib's disclosure rule:

> If you use artificial intelligence ... please explain this in the PR
  description. Explain which tool(s) you used and how you used it.

- Two reports from this year:
  - [July, on Zulip](https://leanprover.zulipchat.com/#narrow/channel/513188-CSLib/topic/Claude.20find.20a.20novel.20proof.2C.20in.20untyped.20lambda.20calculus/near/612724597):
    a proof about η-reduction and strong normalisation, invented by Claude
    and checked with Aristotle, found in no paper or textbook
    ([#860](https://github.com/leanprover/cslib/pull/860)).
  - [September, cut elimination for linear logic](https://github.com/leanprover/cslib/pull/944):
    AI agents that "until recently failed badly" now carry out the proof;
    the library itself has grown enough "to give useful context".

:::notes
46:45. Why disclose: tools make different mistakes than humans, so reviewers
need to know which they are looking for. Both pull requests are still open.
#860 (lengyijun) proves `sn_eta_steps_inv`; the key idea is a counter on
parallel η-reduction. #944 is Fabrizio Montesi's: he had used cut elimination
as a test for AI agents for a while, and credits CSLib's logic developments,
READMEs and `modal` grind set with the change. That is the argument of this
talk from the other side: the library is becoming context for AI.
:::

# The open question

Not whether AI writes Lean. What a *library* has to look like for AI-written
contributions to be reviewable.

- Specifications humans can read.
- Small, stable interfaces that proofs can target.
- Review that scales with volume.

:::fragment
The community is discussing how humans and agents should coordinate. One idea
on the table: *blueprints written by humans*, stating the intent that both
people and agents then work toward.
:::

:::notes
48:00. This is the bridge back to the seminar's theme. The blueprint idea is
from the "Blueprint" topic on the CSLib Zulip (September 2026); present it as
an open discussion, not anyone's position. End of content; the rest is a call
to action.
:::

# Getting involved

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

- Depend on CSLib in your project, and tell us what is missing.
- Bring a pulling project.
- Review a PR, or join the weekly meeting.
- Say hello on the #CSLib channel of the Lean Zulip.

:::notes
49:00. Steer questions toward: what would you want CSLib to have that it
doesn't?
:::

# Thank You

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

*Alexandre Rademaker*

CSLib Initiative, Renaissance Philanthropy · FGV/EMAp

[cslib.io](https://www.cslib.io/) ·
[github.com/leanprover/cslib](https://github.com/leanprover/cslib)

Further reading: Barrett et al., _CSLib: Towards a Lean Computer Science
Library_ (CACM, forthcoming; arXiv:2602.04846). Henson and Montesi,
_Computer Science as Infrastructure_ (FLoC 2026; arXiv:2602.15078).

`alexandre.rademaker@renphil.org`

:::notes
49:45. Questions.
:::
