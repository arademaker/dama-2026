/- Usando a Mathlib: um slide de topo do deck, incluído por `Slides.lean`. -/
module

public import VersoSlides
-- `public`: the elaborated ```lean blocks cannot see a module's private imports.
public import Mathlib.Data.Nat.Prime.Infinite
public import Mathlib.NumberTheory.Real.Irrational
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Positivity

open VersoSlides

-- Without the info panel a code box fits about 85 columns; keep a margin.
set_option verso.code.warnLineLength 80
set_option verso.slides.panel false
set_option linter.unusedVariables false

#doc (Slides) "Usando a Mathlib" =>

%%%
vertical := true
%%%

Teoremas clássicos já estão lá. Basta importar e usar:

```lean -stretch
/-- Euclides: para todo `n` existe um primo maior ou igual a `n`. -/
example (n : ℕ) : ∃ p, n ≤ p ∧ p.Prime :=
  Nat.exists_infinite_primes n

/-- `√2` é irracional. -/
example : Irrational (√2) :=
  irrational_sqrt_two
```

O enunciado é o que importa: quem lê a linha do `example` sabe exatamente o
que foi provado, sem precisar ler a prova.

:::notes
Os nomes seguem uma convenção (`Nat.exists_infinite_primes`), e a busca de
lemas é parte do dia a dia: `exact?`, Loogle, LeanSearch. A prova da
irracionalidade de `√2` na Mathlib tem poucas linhas porque reaproveita fatos
gerais sobre raízes de inteiros.
:::

# ...e a automação faz as contas

Táticas da Mathlib resolvem classes inteiras de problemas:

```lean -stretch
example (a b : ℝ) : (a + b) ^ 2 = a ^ 2 + 2 * a * b + b ^ 2 := by
  ring

example (x : ℝ) : 0 < x ^ 2 + 1 := by
  positivity
```

- `ring`: igualdades em anéis comutativos.
- `positivity`: metas da forma `0 < e` ou `0 ≤ e`.
- Táticas como essas são programas Lean, escritos pela comunidade.

:::notes
Ponto importante para quem programa: as táticas não são parte do núcleo
confiável. Elas produzem um termo de prova, e é o kernel que o confere. Uma
tática com bug não gera uma prova errada; ela falha.
:::
