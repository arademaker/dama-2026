/- Lean como linguagem de programação e como assistente de provas: slides de
topo do deck, incluídos por `Slides.lean`. Só Lean puro, sem Mathlib, para que
os primeiros exemplos não dependam de nada. -/
module

public import VersoSlides

open VersoSlides

-- Without the info panel a code box fits about 85 columns; keep a margin.
set_option verso.code.warnLineLength 80
-- No block produces a proof state worth showing, and the panel costs half the
-- slide width. Re-enable per block with `+panel`.
set_option verso.slides.panel false
set_option linter.unusedVariables false

#doc (Slides) "Lean é uma linguagem de programação" =>

%%%
vertical := true
%%%

Funcional, com tipos estáticos, compilada para C. Funções são definidas por
casos, e `#eval` roda o código:

```lean
/- !hide -/
namespace LeanBasics
/- !end hide -/
def fib : Nat → Nat
  | 0     => 0
  | 1     => 1
  | n + 2 => fib n + fib (n + 1)

#eval fib 10
#eval (List.range 10).map fib
/- !hide -/
end LeanBasics
/- !end hide -/
```

A saída ao lado de cada `#eval` foi calculada pelo Lean quando estes slides
foram gerados.

:::notes
Comece devagar: quem já viu Haskell, OCaml ou F# reconhece o casamento de
padrões. Para os demais, é só uma definição por casos, como no quadro.
`(List.range 10).map fib` aplica `fib` a 0, 1, …, 9. Desça para ver tipos.
:::

# ...tipos, listas e estruturas

```lean
/- !hide -/
namespace LeanBasics
/- !end hide -/
structure Aluno where
  nome  : String
  notas : List Nat

def Aluno.media (a : Aluno) : Nat :=
  a.notas.sum / a.notas.length

def turma : List Aluno :=
  [⟨"Ana", [9, 8, 10]⟩, ⟨"Bruno", [6, 7, 8]⟩]

#eval turma.map fun a => (a.nome, a.media)
#check @Aluno.media
/- !hide -/
end LeanBasics
/- !end hide -/
```

Tudo tem um tipo, e `#check` mostra qual é.

:::notes
Uma estrutura com dois campos, uma função sobre ela, uma lista. A média é
divisão inteira, propositalmente: pergunte o que acontece com a lista vazia
(`0 / 0 = 0` em `Nat`). Esse tipo de pergunta é o que leva a provas.
:::

# Lean é um assistente de provas

Uma proposição é um *tipo*; uma prova é um *programa* desse tipo. O Lean
confere a prova como confere o tipo de qualquer outro termo.

```lean
/- !hide -/
namespace LeanBasics
/- !end hide -/
theorem dois_mais_dois : 2 + 2 = 4 := rfl

theorem soma_zero (n : Nat) : n + 0 = n := rfl

theorem zero_soma (n : Nat) : 0 + n = n := by
  induction n with
  | zero => rfl
  | succ k ih => rw [Nat.add_succ, ih]
/- !hide -/
end LeanBasics
/- !end hide -/
```

Por que `n + 0 = n` sai direto da definição, mas `0 + n = n` precisa de
indução?

:::notes
A adição em `Nat` é definida por recursão no segundo argumento: `n + 0 = n`
é literalmente a primeira equação, por isso `rfl` basta. `0 + n` não reduz,
e a prova é por indução, como no curso de Matemática Discreta.
:::

# ...e a máquina diz não

Uma afirmação falsa não passa, por mais convincente que pareça:

```lean +error
/- !hide -/
namespace LeanBasics
/- !end hide -/
theorem errado (n : Nat) : n - 1 + 1 = n := by
  omega
/- !hide -/
end LeanBasics
/- !end hide -/
```

O contraexemplo é `n = 0`: em `Nat`, `0 - 1 = 0`.

Com a hipótese certa, a mesma tática fecha a prova:

```lean
/- !hide -/
namespace LeanBasics
/- !end hide -/
theorem certo (n : Nat) (h : 0 < n) : n - 1 + 1 = n := by
  omega
/- !hide -/
end LeanBasics
/- !end hide -/
```

:::notes
`omega` decide aritmética linear sobre inteiros e naturais. Ela não "acha"
que a primeira afirmação é falsa: ela simplesmente falha, e a prova não é
aceita. Achar o contraexemplo (`n = 0`) fica por nossa conta. É isso que dá
confiança a uma prova escrita por uma IA: ou passa no verificador, ou não
passa.
:::
