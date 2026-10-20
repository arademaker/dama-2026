/- O programa já é uma especificação: um slide de topo do deck, incluído por `Slides.lean`. -/
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

#doc (Slides) "O programa simples já é a especificação" =>

%%%
vertical := true
%%%

Para saber se um programa rápido está correto, precisamos de uma
especificação. Muitas vezes o programa mais simples que resolve o problema *é*
a especificação: obviamente correto, mas lento demais.

- *Especificação:* ordenação por inserção, seis linhas, nada de esperto.
- *Implementação:* o `mergeSort` verificado da CSLib, no papel da versão
  otimizada que um engenheiro, ou um agente de IA, escreveria.
- *Objetivo:* provar que os dois dão a mesma resposta para toda entrada, e
  contar quantas comparações cada um faz.

Os dois são escritos na *mônada de tempo* `TimeM` da CSLib: um programa
devolve o resultado junto com um custo, e cada `✓` cobra uma comparação.

:::attr («class» := "credits")
Exemplo: Jesse Alama ([@jessealama](https://github.com/jessealama)). Autores na CSLib: Sorrachai ([@sorrachai](https://github.com/sorrachai)), Eric Wieser ([@eric-wieser](https://github.com/eric-wieser)), Kim Morrison ([@kim-em](https://github.com/kim-em)).
:::

:::notes
Este é o exemplo mais longo da palestra: vá devagar, um slide de cada vez
(seta para baixo). Todos já viram os dois algoritmos em Estruturas de Dados;
a novidade é provar coisas sobre eles.
:::

# ...a ordenação óbvia

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
O `✓` é a única coisa que não está no livro-texto: ele cobra uma unidade de
tempo. O modelo de custo é explícito e faz parte do que se confia, como diz a
documentação de `TimeM` na CSLib.
:::

# ...mesma resposta, conta diferente

```lean -stretch
#eval ⟪insertionSort [5, 3, 1, 4, 2]⟫
#eval ⟪mergeSort [5, 3, 1, 4, 2]⟫
#eval (insertionSort (List.range 1000).reverse).time
#eval (mergeSort (List.range 1000).reverse).time
```

:::notes
As saídas foram calculadas na geração dos slides. Com 1000 elementos em
ordem decrescente: 499.500 comparações contra 4.932.
:::

# ...ligada à Mathlib

`⟪p⟫` descarta o custo e fica com o resultado. Sem o custo, a nossa
ordenação por inserção é o `List.insertionSort` da Mathlib:

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

Por que usar as definições da Mathlib: ela já prova que `List.insertionSort`
devolve uma permutação ordenada da entrada. Com um lema de ligação,
reaproveitamos essas provas em vez de refazê-las.

:::attr («class» := "credits")
Autores na Mathlib: Jeremy Avigad ([@avigad](https://github.com/avigad)), Wrenna Robson ([@wrenna-robson](https://github.com/wrenna-robson)).
:::

:::notes
`List.orderedInsert` e `List.insertionSort` são definições da Mathlib, sem
custo. A regra é a mesma da CSLib: não reconstruir o que a Mathlib já tem.
`grind` fecha as duas induções.
:::

# ...equivalentes, para toda entrada

As duas saídas são permutações ordenadas da entrada, e uma lista só tem uma
permutação ordenada:

```lean -stretch
/-- A rápida concorda com a óbvia. Não foi testado. Foi provado. -/
theorem mergeSort_eq_insertionSort (xs : List α) :
    ⟪mergeSort xs⟫ = ⟪insertionSort xs⟫ := by
  obtain ⟨hs, hp⟩ := mergeSort_correct xs
  simpa using List.Perm.eq_of_sortedLE hs.sortedLE List.sortedLE_insertionSort
    (hp.trans (List.perm_insertionSort _ xs).symm)
```

- Da CSLib: `mergeSort_correct`, a saída de `mergeSort` está ordenada e é
  uma permutação de `xs`.
- Da Mathlib: `List.sortedLE_insertionSort` e `List.perm_insertionSort`, o
  mesmo para a inserção; e `List.Perm.eq_of_sortedLE`, duas listas ordenadas
  que são permutações uma da outra são iguais.

:::notes
Quem aceita a versão otimizada é o verificador, não a revisão de código.
Teste mostra que funciona para algumas entradas; prova, para todas.
:::

# ...e o custo de `insertionSort` é `n²`

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

O de `mergeSort` é `n ⌈log₂ n⌉`, como provado na CSLib:

```leanLibCode Cslib.Algorithms.Lean.MergeSort.MergeSort (startLine := 187) (endLine := 190) -stretch
theorem mergeSort_time (xs : List α) :
    let n := xs.length
    (mergeSort xs).time ≤ n * clog 2 n := by
  grind [mergeSort_time_le, timeMergeSortRec_le]
```

:::notes
Uma inserção custa no máximo o tamanho da lista, e ordenar preserva o
tamanho, logo a inserção faz no máximo n² comparações. `clog 2 n` é ⌈log₂ n⌉.
O segundo bloco é citado do código-fonte da CSLib, e a geração dos slides
confere que a citação continua igual ao original. Com a mônada de tempo,
afirmações de desempenho também viram teoremas.
:::

# ...e o verificador diz não

O pior caso exato da inserção é aceito:

```lean -stretch
set_option maxRecDepth 4000 in
example :
    (insertionSort (List.range 100).reverse).time = 100 * 99 / 2 := by
  decide
```

Uma afirmação falsa sobre o merge sort é recusada. Clique em
`native_decide` para ver o motivo:

```lean +error +panel
example  : (mergeSort (List.range 1000).reverse).time = 5000 := by
  native_decide
```

:::notes
`native_decide` compila e roda o código, então confia no compilador do Lean
além do kernel. O `decide` puro fica no kernel, mas não consegue avaliar o
merge sort, que é definido por recursão bem fundada.
:::
