/- Duas máquinas de vendas: um slide de topo do deck, incluído por `Slides.lean`.
Vem do deck da Georgia Tech (arademaker/gatech-2026), com o texto traduzido. -/
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

#doc (Slides) "Duas máquinas de vendas" =>

%%%
vertical := true
%%%

Milner, _Communication and Concurrency_ (1989).

- *Boa:* moeda, e depois _você_ escolhe chá ou café.
  $$`
  \mathit{Good} \stackrel{\text{def}}{=} \mathit{coin}.(\mathit{tea}.\mathit{Good} + \mathit{coffee}.\mathit{Good})`
- *Ruim:* moeda, e _a máquina_ escolhe.
  $$`
  \mathit{Bad} \stackrel{\text{def}}{=} \mathit{coin}.\mathit{tea}.\mathit{Bad} + \mathit{coin}.\mathit{coffee}.\mathit{Bad}`

Os registros são idênticos: `coin tea`, `coin coffee`, … Os mesmos *traços*. Um teste baseado em traços não distingue as duas.

Depois da moeda, a máquina ruim pode já ter escolhido café, e aí o botão do chá não faz nada. Um traço registra as ações que aconteceram; nunca registra uma ação que foi recusada.

:::attr («class» := "credits")
Exemplo: Jesse Alama ([@jessealama](https://github.com/jessealama)). Autor na CSLib: Fabrizio Montesi ([@fmontesi](https://github.com/fmontesi)).
:::

:::notes
Apêndice: só se sobrar tempo ou alguém perguntar o que mais tem na CSLib.
Nenhum código neste slide, de propósito: não se supõe que a plateia conheça
cálculos de processos. A ideia a passar: mesmos registros observáveis,
comportamentos diferentes. Na máquina ruim a escolha acontece na moeda, antes
de o cliente apertar qualquer botão, e nenhum teste baseado em traços vê
isso. Se perguntarem: o must-testing de De Nicola e Hennessy distingue as
duas, justamente porque observa recusas.
:::

# Traços são grosseiros demais

A equivalência de traços ignora quais ações estão disponíveis a cada passo.

*Bissimilaridade*: cada movimento de uma máquina precisa ser imitado por um movimento da outra, e os estados alcançados precisam de novo estar relacionados, a cada passo.

Duas maneiras de provar que as nossas máquinas *não* são bissimilares:

1. *Diretamente*, como faz o `vm_ltsD_ltsND_not_bisim` da própria CSLib: supor uma bissimulação e seguir as transições até ela quebrar.
2. *Com uma lógica:* achar uma fórmula que uma máquina satisfaz e a outra não.

:::notes
O argumento de Milner: traços são a equivalência errada para sistemas que
interagem. A seguir: as máquinas no CCS da CSLib, a semântica do CCS, e as
duas provas.
:::

# ...no CCS da CSLib

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

/-- As duas máquinas vivem num só sistema de transições: o do CCS, da CSLib. -/
abbrev machines := CCS.lts (defs := defs)
```

Um único sistema de transições rotuladas (LTS), `machines`, com duas
constantes: a máquina boa é `const .good`, a ruim, `const .bad`.

:::notes
CCS é uma linguagem para modelar sistemas concorrentes. A CSLib fornece a
sintaxe e a semântica operacional dele como um objeto da biblioteca, um
sistema de transições rotuladas, de que o resto da biblioteca sabe falar.
:::

# ...e a sua semântica

As transições de um processo CCS são uma relação indutiva, uma regra por
construção. A CSLib a declara como um LTS com `@[lts lts]`:

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

As nossas máquinas usam quatro regras: `pre`, `choiceL`, `choiceR` e
`const`, que desdobra uma constante usando `defs`.

:::notes
Formalização direta das regras do livro de Sangiorgi. O bloco é citado do
código-fonte da CSLib, e a geração dos slides confere que a citação continua
igual ao original.
:::

# ...como grafos de transição

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

As duas têm os traços `coin tea`, `coin coffee`, … Depois de `coin`, a
*boa* ainda oferece as duas bebidas; a *ruim* já se comprometeu com uma.

:::notes
É o LTS denotado por `machines`, desenhado: cada caixa é um termo de
processo, cada seta uma transição CCS derivada com as regras do slide
anterior.
:::

# ...não bissimilares, diretamente

Suponha uma bissimulação `r`. Depois de `coin`, a máquina boa tem um único
sucessor, então `r` precisa relacionar `tea.Good + coffee.Good` com
`tea.Bad`. Só o primeiro pode fazer `coffee`:

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
Adaptado do `vm_ltsD_ltsND_not_bisim` da própria CSLib
(`Cslib/Algorithms/CCS/VendingMachine.lean`), que codifica o exemplo de outro
jeito: uma constante `vm` e duas funções de definição, logo dois LTSs. Aqui as
duas máquinas ficam num só LTS porque o lema de HML usado depois trabalha
dentro de um único modelo. `match_deterministic`: se um estado tem um único
sucessor por `coin`, uma bissimulação precisa relacioná-lo a todo sucessor
por `coin` do outro lado.
:::

# Lógica de Hennessy–Milner

Uma lógica modal para sistemas de transições rotuladas. As fórmulas
descrevem que ações um estado pode fazer, e o que vale depois delas:

$$`\begin{aligned}
s \models \langle a\rangle\,\varphi &\iff \exists s'.\; s \xrightarrow{a} s' \text{ and } s' \models \varphi
  && \text{algum } a \text{ é possível, e depois } \varphi \\
s \models [a]\,\varphi &\iff \forall s'.\; s \xrightarrow{a} s' \text{ implies } s' \models \varphi
  && \text{depois de todo } a,\ \varphi
\end{aligned}`

mais `⊤`, `¬` e `∧`.

*Teorema de Hennessy–Milner (1985):*
- Estados bissimilares satisfazem as mesmas fórmulas.
- Para sistemas de imagem finita vale a volta: estados não bissimilares são
  sempre separados por alguma fórmula.

Usamos a primeira direção, que na CSLib é `bisimulation_satisfies`:

```leanLibCode Cslib.Logics.HML.Basic (startLine := 170) (endLine := 172) -stretch
lemma bisimulation_satisfies {hrb : m.lts.IsHomBisimulation r}
    (hv : ∀ {s1 s2}, r s1 s2 → ∀ p, m.v s1 p ↔ m.v s2 p) (hr : r s1 s2)
    (φ : HML.Proposition Label Atom) : ⇓HML[m,s1 ⊨ φ] ↔ ⇓HML[m,s2 ⊨ φ] := by
```

:::attr («class» := "credits")
Autores na CSLib: Fabrizio Montesi ([@fmontesi](https://github.com/fmontesi)), Marco Peressotti ([@mperessotti](https://github.com/mperessotti)), Alexandre Rademaker ([@arademaker](https://github.com/arademaker)).
:::

:::notes
A HML da CSLib é uma instância da sua lógica modal geral; `[a]` é definido
como `¬⟨a⟩¬`. A caracterização completa, nas duas direções, é
`theoryEq_eq_bisimilarity`, no mesmo arquivo; ela só precisa de imagem finita
para a volta. É a volta que torna o método completo: sempre existe uma
fórmula que separa. No nosso exemplo, a fórmula foi escrita à mão.
:::

# ...uma fórmula, na HML da CSLib

Na CSLib, as fórmulas são avaliadas num modelo, um LTS mais uma valoração das
proposições atômicas (`Cslib/Logics/HML/Basic.lean`):

```leanLibCode Cslib.Logics.HML.Basic (startLine := 61) (endLine := 65) -stretch
structure Model State Label Atom where
  /-- The labelled transition system. -/
  lts : LTS State Label
  /-- Valuation of atoms at states. -/
  v : State → Atom → Prop
```

O nosso modelo `m` é o LTS das duas máquinas, sem proposições atômicas
(`Atom := Empty`): só as transições importam. A fórmula `[coin] ⟨tea⟩ ⊤`:
depois de toda `coin`, `tea` é possível.

```lean -stretch
/- !hide -/
open Cslib.Logic.Modal HML
open scoped Cslib.Logic Cslib.Logic.Modal.Proposition
  Cslib.Logic.InferenceSystem Cslib.CCS Cslib.Logic.Modal.HML
/- !end hide -/
/-- Sem proposições atômicas: só as transições importam. -/
abbrev m : HML.Model (Process String Machine) (Act String) Empty :=
  ⟨machines, fun _ _ => False⟩

/-- "Depois de toda moeda, há chá à disposição." -/
def teaAfterCoin : HML.Proposition (Act String) Empty := d[coin] (d⟨tea⟩ ⊤)
```

:::notes
A caixa quer dizer "depois de toda moeda"; o losango, "chá é possível". A
HML é uma instância da lógica modal geral da CSLib, avaliada na semântica do
CCS.
:::

# ...que a máquina boa satisfaz e a ruim não

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

Em `obtain ⟨_, ⟨⟩, ⟨⟩⟩`, cada `⟨⟩` faz análise de casos numa hipótese e a
substitui: depois de uma moeda, a máquina boa tem um único sucessor, e a meta
passa a falar desse sucessor.

:::notes
A máquina ruim tem uma transição por moeda depois da qual chá é impossível,
e essa transição é a testemunha passada à caixa no `have`.
:::

# ...e um teorema

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

Uma fórmula verdadeira para uma máquina e falsa para a outra é um
certificado de que elas não são bissimilares.

:::notes
A CSLib prova que estados bissimilares satisfazem as mesmas fórmulas de HML
(`bisimulation_satisfies`). Basta uma fórmula que separe para concluir que
não são bissimilares: desmontar a bissimulação e aplicar o lema.
:::

# Três partes da CSLib em 35 linhas

- Uma *linguagem*: CCS, com a sua semântica operacional.
- Uma *lógica*: HML, avaliada nessa semântica.
- A *infraestrutura semântica* que liga as duas: sistemas de transições,
  bissimulação, o teorema de Hennessy–Milner.

Linguagens produzem sistemas de transições. Lógicas os consomem. A
metateoria é provada uma vez só.

:::notes
A CSLib também prova que a bissimilaridade é uma congruência para CCS
(`bisimilarity_is_congruence`): componentes equivalentes continuam
equivalentes dentro de qualquer contexto. O que importa aqui é o desenho da
biblioteca: é o que permite conferir um modelo de protocolo escrito por uma
IA contra uma especificação escrita numa lógica, sem cola feita à mão.
:::
