/- How to contribute: a top-level slide of the deck, included by `Slides.lean`. -/
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

#doc (Slides) "How to contribute" =>

%%%
vertical := true
%%%

Depend on it first. That is the fastest way to find what is missing:

```code toml
[[require]]
name = "cslib"
scope = "leanprover"
rev = "<a commit SHA>"   # pin it: `main` moves fast
```

- Most contributions are pull requests, approved by a relevant maintainer.
- Anything cross-cutting: discuss first, on the
  [#CSLib Zulip channel](https://leanprover.zulipchat.com/#narrow/channel/513188-CSLib)
  or an issue.
- Weekly [online meetings](https://lean-lang.org/community/#weekly-cslib-meeting)
- The rules are written down: `CONTRIBUTING.md` (style, documentation, AI
  use) and `DECISION_MAKING.md` (how PRs are reviewed and accepted).

:::notes
12:05. The pin advice is from experience: every downstream project in this talk
pins CSLib by SHA, because following `main` drags your Lean toolchain along.
Press down for how a pull request gets in.
:::

# How a pull request gets in

From `DECISION_MAKING.md`:

- Every PR is reviewed. Anyone may review, and reviewing is a contribution in
  its own right.
- Acceptance needs one maintainer's approval, and every substantive part
  reviewed.
- An objection blocks the merge until it is resolved, by technical discussion
  first. If that fails, the Lead Maintainer decides.
- Reuse over duplication: build on existing definitions, in CSLib or its
  dependencies, unless an alternative has a clear technical benefit.

:::notes
13:05. Optional depth. Consensus "does not require that every participant
prefer the final outcome". New reviewers and maintainers are proposed by the
reviewer or maintainer teams or the steering committee, and need support from
at least half of the eligible voters, with at least one maintainer. Added in
cslib PR #864.
:::
