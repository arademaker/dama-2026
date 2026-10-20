/-
Slides para a V SEEMAp (Semana de Extensão da EMAp, FGV), quarta-feira
2026-10-21, 16h30-18h, Auditório 1429. Público: graduação e pós da EMAp, sem
pressupor Lean nem programação funcional. A sessão tem 90 minutos; o deck é
pensado para uns 70, com perguntas no fim. As notas trazem um relógio
aproximado.

Adaptado da palestra sobre CSLib na Georgia Tech (arademaker/gatech-2026),
com mais contexto e exemplos mais lentos, e com a CSLib no fim em vez de no
centro. A ordem segue os tópicos do README.

As notas do apresentador vão dentro do `index.html` gerado: são públicas.
Nada de finanças da Initiative neste arquivo.
-/
module

public import VersoSlides
-- Os slides com código Lean ou sub-slides verticais ficam em `Slides/`, um por
-- arquivo, e são incluídos abaixo com `{include 1 …}`.
public import Slides.LeanBasics
public import Slides.LeanGame
public import Slides.MathlibExample
public import Slides.WhereItStands
public import Slides.Sorting

open VersoSlides

#doc (Slides) "Lean 4: matemática, código e IA no mesmo lugar" =>

# Lean 4: matemática, código e IA no mesmo lugar

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

Alexandre Rademaker

FGV/EMAp | CSLib Initiative, Renphil

V SEEMAp, FGV EMAp | 21 de outubro de 2026

[arademaker.github.io/dama-2026](https://arademaker.github.io/dama-2026/)

# Sobre mim

- *Mestrado* (UFF, 2005): métodos formais, lógica de reescrita em
  [Maude](https://maude.cs.illinois.edu).
- *Doutorado* (PUC-Rio, 2010): teoria da prova para lógicas de descrição.
  Estágios no [SRI](https://www.csl.sri.com/) (PVS) e na [Microsoft Research](https://www.microsoft.com/en-us/research/),
  com a equipe do [Z3](https://github.com/Z3Prover/z3).
- *IBM Research Brasil* (2012–2025): PLN, semântica computacional, ontologias.

- *Professor da EMAp* desde 2010: matemática discreta, programação,
  algoritmos, teoria dos tipos, teoria das categorias, etc.
- Na comunidade Lean desde março de 2015. Diretor da CSLib Initiative, na Renaissance Philanthropy.

:::notes
Agradecer à comissão da SEEMAp e ao DAMA. Slide rápido: o fio é lógica
e métodos formais, depois linguagem e representação de conhecimento, e agora
de volta às provas, com o Lean.
:::

# Roteiro

1. *O que é o Lean*: uma linguagem de programação que também confere provas.
2. *Por que agora*: o que aconteceu nas últimas semanas, e nos últimos meses.
3. *O momentum*: de projeto de pesquisa a infraestrutura.
4. *A Mathlib*: a biblioteca de matemática.
5. *IA e Lean*: por que um verificador é o parceiro natural de um modelo.
6. *Ao vivo*: um programa com provas, escrito aqui, no VS Code.
7. *A CSLib*, e *como começar*.

:::notes
Avisar que todo bloco de código nos slides foi conferido pelo Lean quando o
deck foi gerado. Primeira metade em slides, segunda metade ao vivo.
:::

# Parte 1: O que é o Lean

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
2:00.
:::

# O que é o Lean?

{image "static/images/lean-logo.png" (width := "18%")}[Logo do Lean]

[lean-lang.org](https://lean-lang.org): _a proof assistant and programming
language that is transforming how we approach mathematics, software
verification, and AI._

- Uma *linguagem de programação funcional* e um *assistente de provas*, no
  mesmo sistema.
- Provas *conferidas pela máquina*, por um *kernel* pequeno e confiável.
- Baseado em *teoria dos tipos dependentes*.
- Escrito em Lean, e *muito extensível*: a comunidade cria suas próprias
  táticas e notações.
- *325.000+* instalações únicas da extensão para VS Code.

:::attr («class» := "credits")
Este slide e o do "jogo" são adaptados do deck FROCON 2026 de Leo de Moura ([@leodemoura](https://github.com/leodemoura)).
:::

:::notes
Criado por Leonardo de Moura em 2013, na Microsoft Research; hoje
mantido pela Lean FRO, uma organização sem fins lucrativos. Contagem de
instalações: VS Code (184 mil) + Open VSX (141 mil), números do deck de Leo.
:::

{include 1 Slides.LeanGame}

# Em quem confiar?

O Lean separa *quem procura* a prova de *quem confere* a prova.

- Táticas, automação, e agora modelos de IA, *procuram* provas. Podem ser
  grandes, complicados, cheios de bugs.
- O *kernel* só *confere* o termo de prova final. É pequeno, e pode ser
  reimplementado de forma independente.
- Para confiar num teorema, basta ler o *enunciado* e confiar no kernel.

> If your proof type-checks, it's correct.

  — Leonardo de Moura, [_Why Lean?_](https://leodemoura.github.io/blog/2026-4-2-why-lean/) (abril de 2026)

:::notes
Este é o slide-chave para o resto da palestra: é por isso que faz
sentido deixar uma IA escrever provas. Há várias implementações
independentes do kernel, e o Comparator, ferramenta da FRO, confere as provas
em mais de uma delas.
:::

# Parte 2: Por que Lean, e por que agora

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
7:00.
:::

# Só na última semana

- *16/10*: [_How to Formalize All of Mathematics_](https://xenaproject.wordpress.com/2026/10/16/how-to-formalize-all-of-mathematics/),
  de Avigad, Buzzard, Commelin, Degenne, Morrison, Nash e Topaz. A Mathlib
  recebeu o *Prêmio Jean-Pierre Demailly 2026* de Ciência Aberta em
  Matemática.
- *17/10*: [_Starting a new journal_](https://terrytao.wordpress.com/2026/10/17/starting-a-new-journal/),
  post de Shaoming Guo no blog de Terence Tao:

> To be accepted, a paper will need to have its proofs formally verified in
  Lean.

:::notes
Uma revista de matemática que exige prova verificada em Lean para
aceitar um artigo. O post é de Shaoming Guo, convidado no blog do Tao. Os
valores declarados: "Prioritizing understanding over being first" e
"Ensuring rigor through formal verification". O post do Xena também diz que
"a lousy formalization of existing results is worse than no formalization at
all": formalizar bem é um ofício.
:::

# 2026 até aqui

:::table +colHeaders +rowSeps
*
  * Quando
  * O quê
*
  * jan
  * [AxiomProver resolve 8 dos 12 problemas do Putnam](https://github.com/AxiomMath/putnam2025)
*
  * mar
  * [Empacotamento de esferas em dimensões 8 e 24 formalizado](https://www.math.inc/sphere-packing)
    (resultados de Viazovska, Medalha Fields)
*
  * abr
  * [ChatGPT 5.5](https://openai.com/index/introducing-gpt-5-5/) encontra um resultado de Ramsey verificado em Lean
*
  * jul
  * Lançamento do [Tau Ceti](https://taucetiproject.org/)
*
  * ago
  * OpenAI: [dez problemas em aberto](https://openai.com/index/ten-advances-in-mathematics/),
    com [certificados em Lean](https://github.com/openai/ten-proofs)
*
  * set
  * Anthropic [formaliza o Último Teorema de Fermat](https://www.anthropic.com/research/formalizing-fermats-last-theorem);
    OpenAI: [Navier–Stokes](https://openai.com/index/navier-stokes-solution/),
    com [prova em Lean](https://github.com/openai/NavierStokesAndEuler)
:::

:::notes
Linha do tempo da página da Lean FRO, "A Brief History of Lean"
(lean-lang.org/fro/about), de onde vêm também os links. Em agosto, a
Anthropic também publicou resultados sobre a função zeta de Riemann, com
formalização em Lean (anthropic.com/research/riemann-zeta). Segundo o post do Xena (16/10), a formalização de
Fermat pelo Claude teve 13 milhões de linhas, escritas em 11 dias; Kevin
Buzzard elogiou o resultado e segue com a sua própria formalização, de uma
prova mais moderna. Também em setembro: o GPT-6 Astra ajudou a chegar a um
limite de 186 para intervalos entre primos, com formalização em Lean.
:::

# Agosto: dez avanços

[OpenAI, 1º de agosto](https://openai.com/index/ten-advances-in-mathematics/):
dez resultados, cada um resolvendo ou avançando um problema em aberto.

- Empacotamento de esferas em dimensão alta; códigos binários e esféricos.
- Grupos não sóficos existem; a conjectura de rigidez de Connes é falsa.
- Números de Ramsey multicolor (problema de Erdős 183).
- Complexidade de circuitos aritméticos, repetição paralela quântica, …

> Afterward, the model formalized each argument in a Lean certificate.

:::notes
Resultados de uma versão interna do Astra. Segundo o post, encontrar as
soluções custaria cerca de US$ 2.000 em tokens. Os manuscritos foram
preparados por pessoas, com o mesmo modelo, e o modelo depois formalizou cada
argumento em Lean. Artigo: cdn.openai.com/pdf/ten-proofs-oai.pdf. O post cita
a declaração de Leiden sobre IA e matemática e defende que a autoria reflita
como o resultado foi produzido.
:::

# Setembro: Navier–Stokes

[OpenAI, 8 de setembro](https://openai.com/index/navier-stokes-solution/): um
fluido que parte do repouso, com uma força externa suave, desenvolve
velocidade infinita em tempo finito, com energia finita.

- Segundo a OpenAI, isso estabelece as alternativas (C) e (D) do enunciado
  oficial do Problema do Milênio.
- Cerca de *10.000 agentes* simultâneos; *88 horas* até a prova.
- Formalização e verificação em Lean: mais *17 horas*.
- Prova em Lean: [github.com/openai/NavierStokesAndEuler](https://github.com/openai/NavierStokesAndEuler).

:::notes
Formular com cuidado: "segundo a OpenAI". O post diz que não pretendem
reivindicar o prêmio. O mesmo sistema resolveu antes o problema de Euler sem
força externa. Em paralelo, Levent Alpöge (Anthropic) e Tristan Buckmaster
(NYU) resolveram o problema de Euler com força externa; a OpenAI reconhece a
prioridade deles nesse caso. O repositório explica como conferir as provas
com o Comparator, de forma independente.
:::

# Por que isso importa

Uma prova gerada por IA pode ter milhares de linhas. *Quem confere?*

- Revisão humana não escala.
- Teste não serve: um teorema fala de *todos* os casos.
- O kernel do Lean confere, e não se cansa.

O gargalo deixa de ser *escrever* a prova e passa a ser *enunciar* o
problema certo.

:::notes
Ligar com o slide "Em quem confiar?". Para quem faz matemática
aplicada: o enunciado continua sendo trabalho humano, e é onde mora o erro
mais perigoso, o de provar a coisa errada.
:::

# Parte 3: O momentum do Lean

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
17:00.
:::

# Uma breve história

:::table +colHeaders +rowSeps
*
  * Quando
  * Marco
*
  * jul 2013
  * [Primeiro commit](https://github.com/leanprover/lean3), de Leonardo de Moura
*
  * jan 2017
  * Lean 3; em julho nasce a [mathlib](https://github.com/leanprover-community/mathlib3)
*
  * out 2019
  * [Natural Number Game](https://adam.math.hhu.de/#/g/leanprover-community/nng4) 1.0
*
  * jul 2021
  * [Liquid Tensor Experiment](https://www.quantamagazine.org/lean-computer-program-confirms-peter-scholze-proof-20210728/)
    concluído (desafio de Peter Scholze)
*
  * jul–set 2023
  * [Lean FRO](https://lean-lang.org/fro/) fundada;
    [Mathlib](https://github.com/leanprover-community/mathlib4) portada para
    Lean 4; Lean 4.0
*
  * jun–jul 2024
  * [Harmonic](https://harmonic.fun/), primeira startup baseada em Lean;
    [AlphaProof](https://deepmind.google/discover/blog/ai-solves-imo-problems-at-silver-medal-level/),
    prata na IMO
*
  * mai–set 2025
  * [50+ cursos](https://leanprover-community.github.io/teaching/courses.html)
    universitários; tática [`grind`](https://lean-lang.org/doc/reference/latest/releases/v4.22.0/#release-v4___22___0);
    [Mathlib Initiative](https://mathlib-initiative.org/)
*
  * jun 2026
  * A história vira livro: [_The Proof in the Code_](https://www.quantabooks.org/books/the-proof-in-the-code/)
:::

:::notes
Fonte: "A Brief History of Lean", lean-lang.org/fro/about. A FRO é uma
organização sem fins lucrativos sob a Convergent Research, fundada por
Leonardo de Moura e Sebastian Ullrich. Meses, pela página: mathlib, jul
2017; porte para Lean 4 e fundação da FRO, jul 2023 (o post "Why Lean?" diz
agosto para a FRO); Lean 4.0, set 2023; Harmonic, jun 2024; AlphaProof, jul
2024; 50+ cursos, mai 2025; `grind`, ago 2025 (Lean 4.22); Mathlib
Initiative, set 2025. O LTE começou em dez 2020. O livro de Hartnett está na linha do tempo da
FRO em jun 2026; o slide "Virou livro" vem logo depois.
:::

# IA nas olimpíadas

- *IMO 2024*: AlphaProof (Google DeepMind), nível prata.
- *IMO 2025*: Aristotle (Harmonic), nível ouro; SEED Prover (ByteDance),
  nível prata.

*As três usaram Lean.*

Por quê: tipos expressivos, uma grande biblioteca e um ecossistema
programável (Leonardo de Moura, [_Proof Assistants in the Age of AI_](https://leodemoura.github.io/blog/2026-2-18-proof-assistants-in-the-age-of-ai/),
fevereiro de 2026).

:::notes
Pushmeet Kohli (DeepMind) creditou a
"extensibility and verification capabilities" do Lean. No mesmo post, sobre
o uso de IA na própria FRO: "we cannot imagine building Lean without it".
:::

# Virou livro

Kevin Hartnett, [_The Proof in the Code: How a Truth Machine Is Transforming
Math and AI_](https://www.quantabooks.org/books/the-proof-in-the-code/)
(Quanta Books, junho de 2026).

> Lean is one of the most important things happening to math right now.

  — Grant Sanderson (3Blue1Brown)

:::notes
O livro conta a história do Lean: concebido para conferir código, e
adotado por um pequeno grupo de matemáticos que viu nele um "oráculo da
verdade". Também traz a conversa entre Pushmeet Kohli e Leonardo de Moura que
está na origem da CSLib.
:::

# Parte 4: A Mathlib

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
21:00.
:::

# Mathlib: a biblioteca de matemática do Lean

Criada em julho de 2017, em Lean 3. Aberta e mantida pela comunidade. *Hoje*:

:::hstack
- *280.000+* teoremas formalizados.
- *2,4M+* linhas de Lean. *50.000+* linhas de extensões.
- *950* contribuidores e *65* revisores.
- *1.500+* classes de tipos, *20.000+* instâncias.
- [github.com/leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4)

{image "static/images/mathlib-deps.png" (width := "100%")}[Grafo de dependências da Mathlib]
:::

:::notes
Teoremas, linhas, classes e instâncias: deck FROCON 2026 de Leo.
Contribuidores e revisores: post do Xena (16/10/2026). A Mathlib recebeu o
Prêmio Jean-Pierre Demailly 2026 de Ciência Aberta em Matemática. As extensões (táticas, linters,
automação) foram escritas pela comunidade sem coordenação do time do Lean.
:::

# O que tem dentro

:::table +colHeaders +rowSeps
*
  * Área
  * Exemplos
*
  * Álgebra
  * Grupos, anéis, corpos, teoria dos números, álgebra homológica
*
  * Álgebra linear
  * Espaços vetoriais, matrizes, formas bilineares
*
  * Topologia e análise
  * Espaços de Banach e Hilbert, medida e integração, análise complexa e de Fourier
*
  * Probabilidade
  * Variáveis aleatórias, processos estocásticos
*
  * Geometria
  * Variedades, geometria riemanniana e algébrica
*
  * Combinatória
  * Grafos, teoria de Ramsey, combinatória aditiva
*
  * Lógica e computação
  * Computabilidade, teoria dos modelos, teoria dos conjuntos
:::

[Visão geral da Mathlib](https://leanprover-community.github.io/mathlib-overview.html)

:::notes
Boa parte do currículo da graduação da EMAp está aqui. Vale mostrar a
página da visão geral ao vivo, se houver tempo.
:::

{include 1 Slides.MathlibExample}

# Parte 5: IA e Lean

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

:::notes
26:00.
:::

# Um verificador é o parceiro natural de um modelo

- Modelos de linguagem *erram com confiança*. O kernel não aceita confiança.
- Para treinar com reforço, um agente precisa de um sinal de recompensa que
  ele *não consiga trapacear*. Uma prova conferida é esse sinal.
- A Mathlib é também um *dado*: centenas de milhares de teoremas, escritos
  e anotados por pessoas.

Leituras: [_Proof Assistants in the Age of AI_](https://leodemoura.github.io/blog/2026-2-18-proof-assistants-in-the-age-of-ai/),
[_Teaching AI to Make Proof Automation Work_](https://leodemoura.github.io/blog/2026-3-14-teaching-ai-to-make-proof-automation-work/),
[_Why Lean?_](https://leodemoura.github.io/blog/2026-4-2-why-lean/) ·
Comunidade: [FMxAI](https://fmxai.org), métodos formais × IA

:::notes
FMxAI é a série de encontros, só para convidados, organizada pela
Atlas Computing, onde trabalhei no projeto Specification IDE: "Proof-grade
software, at the speed of AI". A próxima edição é em Londres, em março de
2027. Do segundo post: a proposta é usar as anotações humanas da Mathlib
(`[simp]`, `[grind]`) como base supervisionada, para ensinar IA a escrever
boas anotações. "Most mathematicians can write proofs, but they can't write
good annotations."
:::

# Tau Ceti: matemática escrita por agentes

[taucetiproject.org](https://taucetiproject.org/), lançado em julho de 2026:

- *Agentes de IA* escrevem as provas em Lean e abrem pull requests.
- *Matemáticos* definem os alvos, num roteiro revisado por pessoas.
- *Revisores de IA* julgam cada PR por critérios fixos e abertos.
- Todo teorema é conferido pela máquina: sem `sorry`, sem axiomas extras.

Segundo o post do Xena (16/10), o Tau Ceti já é um pouco *maior que a
Mathlib*.

:::notes
Exemplos que a página confere a cada build: teorema de Burnside,
extensão de Carathéodory na fronteira, dualidade de Schur–Weyl. Pergunta para
a plateia: o que muda no trabalho do matemático quando escrever a prova deixa
de ser o gargalo?
:::

# Software também: lean-zip

[lean-zip](https://github.com/kim-em/lean-zip) (Kim Morrison): DEFLATE em Lean
puro, com um teorema conferido pelo kernel: descomprimir desfaz comprimir,
para toda entrada e todo nível. Cerca de 1.100 teoremas, nenhum `sorry`.

- *Escrito por agentes de IA*, com pouca supervisão.
- *A prova é o portão*: um PR só entrava se a prova continuasse valendo.
- *Por isso otimizar é seguro*: ficou mais rápido que o `miniz_oxide` do Rust
  com a mesma taxa de compressão.

:::notes
Fatos do README do lean-zip (set/2026): cerca de 32 mil linhas de
prova; no nível 6, uns 30% mais rápido que o `miniz_oxide` com a mesma taxa.
Kim: a prova de correção "allows us to let AIs loose optimizing the code".
Transição: para fazer isso com software em geral, falta vocabulário. É aí que
entra a CSLib.
:::

# Um exemplo: busca binária escrita por IA

[lean-binsearch](https://github.com/arademaker/lean-binsearch): implementação
e prova feitas com o [Claude Code](https://claude.ai/code), 283 linhas. Para
confiar no resultado, basta ler dois enunciados:

```code lean
theorem bsearch_sound (l : List Nat) (target : Nat) (i : Nat) :
    bsearch l target = some i → l[i]? = some target

theorem bsearch_complete (l : List Nat) (target : Nat)
    (hs : Sorted l) (hm : target ∈ l) :
    ∃ i, bsearch l target = some i
```

- *Correção*: se devolve `i`, então `target` está na posição `i`.
- *Completude*: se a lista está ordenada e contém `target`, a busca acha.

:::fragment
E se escrevêssemos uma busca binária juntos, agora, deixando o Lean nos
corrigir?
:::

:::notes
Este bloco é citado, não conferido pelo deck: o projeto usa outra versão
do Lean (v4.29.0). A recursão é bem fundada, na medida `hi + 1 - lo`. Pergunta
para a plateia: o enunciado de completude precisa da hipótese `Sorted l`, e o
de correção não. Por quê?
:::

# Parte 6: Ao vivo

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

Vamos escrever juntos um programa em Lean, com provas, no VS Code.

A ideia e o roteiro são do *live demo* de Joachim Breitner (Lean FRO):
[github.com/nomeata/lean-highlights-tfp](https://github.com/nomeata/lean-highlights-tfp).

:::notes
35:00. Abrir o VS Code em `Demo/BinSearchLive.lean`; o roteiro está em
`ROTEIRO.md` e o gabarito em `Demo/BinSearch.lean`. Fonte grande, painel
do Lean (Infoview) aberto à direita. Se algo der errado, o apêndice tem os
exemplos em slides.
:::

# Bingo

Marque o que aparecer durante a demonstração:

:::table +rowSeps
*
  * programação funcional básica (*basic functional programming*)
  * estruturas (*structures*)
*
  * tipos dependentes (*dependent types*)
  * avaliar código (*evaluating code*)
*
  * testes embutidos (*embedded tests*)
  * informação ao passar o mouse (*hover*)
*
  * atualização imutável (*immutable updates*)
  * recursão bem fundada (*well-founded recursion*)
*
  * terminação automática (*automatic termination checking*)
  * parâmetros automáticos (*auto-params*)
*
  * automação com `grind` (*automation with `grind`*)
  * inspecionar o estado do `grind` (*inspecting grind states*)
*
  * provas com táticas (*tactic proofs*)
  * indução funcional (*functional induction*)
*
  * dicas embutidas no texto (*inlay hints*)
  * sugestões clicáveis (*clickable hints*)
*
  * notação própria (*custom notation*)
  * notação `do` (*do notation*)
*
  * lambdas anônimas (*anonymous lambdas*)
  * ir para a definição (*go to definition*)
:::

:::attr («class» := "credits")
Lista adaptada do "Lean Highlights Bingo" de Joachim Breitner ([@nomeata](https://github.com/nomeata)).
:::

:::notes
A lista completa (33 itens) está em `ROTEIRO.md`, para imprimir. Pedir
para a plateia gritar "bingo!" quando completar uma linha.
:::

# Parte 7: A CSLib

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

A busca binária escrita pela IA definia o seu próprio `Sorted`, sem usar a
Mathlib nem a CSLib. Cada projeto reinventando o vocabulário: é esse o
problema que uma biblioteca resolve.

:::notes
70:00.
:::

# O que é a CSLib?

> An open-source library of reusable components for proving theorems in
  computer science and writing formally verified code in the Lean
  programming language and proof assistant.

- *Formalizar a ciência da computação*: modelos de computação, semântica,
  lógicas, algoritmos e estruturas de dados, com provas de correção *e* de
  complexidade.
- *Raciocinar sobre código do dia a dia*: Boole, uma linguagem intermediária
  de verificação embutida no Lean.
- Depende da Mathlib, e não refaz o que a Mathlib já tem.

[github.com/leanprover/cslib](https://github.com/leanprover/cslib) ·
[cslib.io](https://www.cslib.io/)

:::notes
Dirijo a CSLib Initiative na Renaissance Philanthropy, que apoia a
biblioteca; a biblioteca em si é da comunidade. Mantenha curto: o exemplo a
seguir explica melhor do que a lista.
:::

# CSLib no ensino

- [Software Foundations in Lean](https://github.com/plclub/sf-in-lean/):
  Benjamin Pierce, Michael Hicks e Harry Goldstein adaptam o texto clássico
  de métodos formais para Lean.
- [Functional Algorithm Design](https://github.com/cslib-community/fad):
  algoritmos funcionais, com provas.
- [Computational Semantics with Lean](https://emap-nlp.github.io/book/): o
  livro do curso de PLN da EMAp, deste semestre, escrito em Verso como estes
  slides.

:::notes
O CSwL é feito aqui: quem está no curso já está usando Lean. Os três
projetos usam a CSLib e devolvem para ela o que é geral.
:::

# A comunidade em volta da CSLib

[github.com/cslib-community](https://github.com/orgs/cslib-community/repositories):
projetos construídos com, em volta de, e para a CSLib.

:::table +colHeaders +rowSeps
*
  * Projeto
  * O quê
*
  * `CSwL`
  * Semântica computacional com Lean (o livro do curso da EMAp)
*
  * `fad`
  * Projeto de algoritmos funcionais
*
  * `AlgoLib`
  * Algoritmos em grafos, com provas de correção e de tempo
*
  * `alc`
  * A lógica de descrição básica, ALC
*
  * `sqlean`
  * Formalização do SQLite em Lean
*
  * `bignum`
  * Porte das provas do s2n-bignum (Amazon) para Lean
*
  * `EpsilonEridani`
  * Agentes de IA escrevem o Lean; pessoas decidem o que vale provar
:::

:::notes
É onde os projetos vivem antes de levar à CSLib o que for geral. Bons
pontos de partida para IC e TCC: cada um tem pedaços pequenos e bem
delimitados.
:::

# Como começar

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

- *Jogar*: [Natural Number Game](https://adam.math.hhu.de/#/g/leanprover-community/nng4).
- *Programar*: [Functional Programming in Lean](https://lean-lang.org/functional_programming_in_lean/).
- *Provar*: [Theorem Proving in Lean 4](https://lean-lang.org/theorem_proving_in_lean4/)
  e [Mathematics in Lean](https://leanprover-community.github.io/mathematics_in_lean/).
- *Aprofundar*: [_Lean 4 for Program Verification in the Age of AI_](https://leodemoura.github.io/static/marktoberdorf2026/),
  quatro aulas de Leonardo de Moura (Marktoberdorf, agosto de 2026).
- *Conversar*: o [Zulip do Lean](https://leanprover.zulipchat.com).
- *Contribuir*: Mathlib e CSLib aceitam PRs, e revisar também é contribuir.

:::notes
76:00. Para quem quer fazer IC ou TCC com Lean: me procurem. Passar o link do
deck de novo.
:::

# Obrigado

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

*Alexandre Rademaker*

FGV/EMAp · CSLib Initiative, Renaissance Philanthropy

[arademaker.github.io/dama-2026](https://arademaker.github.io/dama-2026/)

`alexandre.rademaker@renphil.org`

:::notes
80:00. Perguntas.
:::

# Apêndice

%%%
backgroundGradient := "linear-gradient(135deg, #CCAE8E 5%, #B8936F 40%, #A0704A 100%)"
%%%

Exemplos em slides, para o caso de a demonstração ao vivo falhar.

{include 1 Slides.LeanBasics}

{include 1 Slides.Sorting}

{include 1 Slides.WhereItStands}
