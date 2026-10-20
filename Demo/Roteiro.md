# Roteiro: Lean 4 na V SEEMAp

Quarta-feira, 21/10/2026, 16h30–18h, Auditório 1429 (FGV, Rio).
Slides: <https://arademaker.github.io/dama-2026/>

O live demo é adaptado do "Lean Highlights" de **Joachim Breitner** (Lean FRO):
<https://github.com/nomeata/lean-highlights-tfp>. A ideia, o exemplo e a
sequência são dele. Dar o crédito em voz alta ao abrir o VS Code.

## A sessão

| Relógio     | Min.  | Bloco                                              | Slides              |
|-------------|-------|----------------------------------------------------|---------------------|
| 16h30       | 0     | Abertura, sobre mim, roteiro                       | 1–3                 |
| 16h32       | 2     | Parte 1: o que é o Lean (jogo, em quem confiar)    |                     |
| 16h37       | 7     | Parte 2: por que agora (Tao, Xena, OpenAI)         |                     |
| 16h47       | 17    | Parte 3: momentum (história, olimpíadas, livro)    |                     |
| 16h51       | 21    | Parte 4: Mathlib (+ exemplo com `ring`)            |                     |
| 16h56       | 26    | Parte 5: IA e Lean (Tau Ceti, busca binária, zip)  |                     |
| **17h05**   | 35    | **Parte 6: ao vivo** (slide "Bingo", depois VS Code) | Ao vivo, Bingo    |
| 17h40       | 70    | Parte 7: CSLib (curta)                             |                     |
| 17h46       | 76    | Como começar                                       |                     |
| 17h50       | 80    | Obrigado; perguntas                                |                     |
| 18h00       | 90    | Fim                                                |                     |

Se às **17h10** o demo ainda não começou, cortar a Parte 3 ou a Parte 4 na
volta. O apêndice (exemplos em slides) é o plano B se o VS Code falhar.

## Antes de começar (no auditório)

- [ ] `git pull` e `make demo` no notebook (o gabarito compila).
- [ ] Abrir a pasta `dama-2026` no VS Code e esperar o Lean carregar.
- [ ] Abrir `Demo/BinSearchLive.lean` (para escrever) e deixar
      `Demo/BinSearch.lean` (gabarito) numa aba ao lado.
- [ ] Infoview do Lean aberta à direita (`Ctrl+Shift+Enter` ou o ∀ no canto).
- [ ] Fonte grande: `Cmd+=` duas ou três vezes; conferir do fundo da sala.
- [ ] Hover: neste repositório o hover do mouse só aparece segurando `Option`
      (`.vscode/settings.json`). Para mostrar um hover pelo teclado:
      `Cmd+K Cmd+I`.
- [ ] Navegador numa aba com <https://loogle.lean-lang.org>.
- [ ] Notificações desligadas (Não perturbe).

## O demo, passo a passo (≈ 30 min)

Em cada etapa: o que digitar, o que o Lean responde, e o que dizer. O ritmo
de Joachim: **deixar o Lean reclamar, ler a mensagem em voz alta, e só então
corrigir**. Os erros abaixo foram conferidos com o toolchain deste projeto.

### Etapa 1: a estrutura (2 min, até 17h07)

```lean
structure Map β where
  keys : Array Nat
  values : Array β
```

- `β` se digita `\b`. Passar o mouse (com `Option`) sobre `β` e sobre `Array`:
  o hover mostra o tipo e a documentação.
- Dizer: chaves ordenadas num vetor, valores em outro, na mesma posição.

Bingo: *structures*, *unicode entry*, *hover*.

### Etapa 2: `update` com busca binária (5 min, até 17h12)

```lean
def Map.update (k : Nat) (v : β) (m : Map β) := go 0 m.keys.size
where
  go (i j : Nat) :=
    if i ≥ j then
      m
    else
      if i + 1 = j then
        { m with values := m.values.setIfInBounds i v }
      else
        let mid := (i + j)/2
        let k' := m.keys[mid]!
        if k < k' then
          go i mid
        else
          go mid j
```

- Mostrar o `{β}` cinza depois de `Map.update`: o Lean deduziu o parâmetro
  implícito (*inlay hint*).
- `{ m with values := … }`: cria uma cópia com um campo trocado (*immutable
  update*).
- Não há prova de terminação: o Lean descobriu sozinho que `j - i` diminui.
- `m.keys[mid]!`: o `!` confere o índice em tempo de execução.

Bingo: *basic functional programming*, *inlay hints*, *immutable updates*,
*automatic termination checking*, *overloaded dot notation*.

### Etapa 3: testar (4 min, até 17h16)

```lean
def testMap : Map Nat where
  keys := #[1,3,5,7]
  values := #[1,3,5,7]

#eval testMap.update 3 42
```

Resposta: `{ keys := #[1, 3, 5, 7], values := #[1, 42, 5, 7] }`. Certo.

Agora transformar em teste: escrever `#guard_msgs in` acima do `#eval`. O
Lean reclama que a docstring não bate; clicar na lâmpada (*code action*) e ele
escreve a resposta esperada:

```lean
/-- info: { keys := #[1, 3, 5, 7], values := #[1, 42, 5, 7] } -/
#guard_msgs in
#eval testMap.update 3 42
```

**O momento do bug.** Copiar o teste trocando `3` por `4` (chave que não
existe) e *sem mudar a docstring*. O teste **passa**! Atualizar a chave 4
gravou 42 na posição da chave 3. Perguntar à plateia por quê: o caso base
nunca confere se achou a chave.

Corrigir (e mostrar que agora o segundo teste falha, como deveria):

```lean
      if i + 1 = j then
        if m.keys[i]! = k then
          { m with values := m.values.setIfInBounds i v }
        else
          m
```

Atualizar a docstring do segundo teste pela lâmpada:
`values := #[1, 3, 5, 7]`.

Bingo: *evaluating code*, *embedded test*, *clickable hints*.

### Etapa 4: índices seguros, o Lean pede provas (6 min, até 17h22)

Apagar o `!` de `m.keys[i]!`. Erro:

```
failed to prove index is valid, possible solutions: …
⊢ i < m.keys.size
```

- Ler as sugestões em voz alta. Dizer: o Lean não aceita um acesso que
  *pode* sair do vetor; ele quer uma prova.
- Dar nome à condição, `if h : i + 1 = j then`: o fato entra no contexto,
  mas ainda falta relacionar `j` com o tamanho.
- Acrescentar a `go` as hipóteses de que precisamos:
  `go (i j : Nat) (hi : i ≤ j) (hj : j < m.keys.size) :=`
- Apagar também o `!` de `m.keys[mid]!`.
- As chamadas recursivas reclamam. Pôr `_ _` (`go i mid _ _`): o Lean mostra
  o que falta provar (`⊢ i ≤ mid`, `⊢ mid < m.keys.size`).
- Trocar cada `_` por `(by grind)`. Tudo some.
- Melhor: mover a prova para a declaração (*auto-param*), e limpar as
  chamadas:
  `go (i j : Nat) (hi : i ≤ j := by grind) (hj : j < m.keys.size := by grind) :=`
- Agora `go 0 m.keys.size` reclama: `m.keys.size < m.keys.size` é falso! Trocar
  `<` por `≤` em `hj`.
- Os `if h :` podem virar `if _ :` (não usamos os nomes; o `grind` acha os
  fatos no contexto sozinho).

Bingo: *dependent types*, *auto-params*, *implicit parameters with
auto-tactics*, *automation with `grind`*.

### Etapa 5: `grind` acha um contraexemplo (3 min, até 17h25)

Trocar `setIfInBounds` (que ignora índice inválido em silêncio) por `set`,
que exige prova:

```lean
          { m with values := m.values.set i v (h := by grind) }
```

`grind` falha, e mostra por quê. Abrir *Goal diagnostics* na Infoview: há um
caso com `m.values.size = 0` e `m.keys.size ≠ 0`. **Nada impede um `Map` com
mais chaves que valores.** O `grind` encontrou um contraexemplo de verdade.

Bingo: *inspecting grind states*.

### Etapa 6: um invariante na estrutura (5 min, até 17h30)

```lean
structure Map β where
  keys : Array Nat
  values : Array β
  hSize : keys.size = values.size
```

- Agora todo `Map` carrega uma prova de que os tamanhos batem.
- Usar: `(h := by grind [Map.hSize])`. A prova do índice passa, mas surge outro
  erro: o `{ m with … }` reaproveita a prova antiga, que fala do vetor antigo.
  Dar a nova prova: `hSize := by grind [Map.hSize]`.
- Em vez de repetir `[Map.hSize]`, ensinar o `grind` uma vez:
  `attribute [grind] Map.hSize`. O Lean sugere padrões (*Try these*): escolher
  `attribute [grind =] Map.hSize` e tirar os `[Map.hSize]`.
- `testMap` reclama: falta o campo. `hSize := rfl`.
- Os dois testes reclamam: a saída agora tem `hSize := _`. Lâmpada nos dois.

Ponto de chegada desta etapa = `Demo/BinSearch.lean` sem os teoremas.

### Etapa 7: provar (5 min, até 17h35)

Primeiro o enunciado, sem prova:

```lean
theorem Map.update_eq_self (m : Map β) (h : k ∉ m.keys) :
    m.update k v = m := sorry
```

- Dizer: os testes conferem dois casos; o teorema fala de *todos* os mapas e
  *todas* as chaves ausentes.
- Precisamos de um lema sobre `go`, com as hipóteses explícitas:

```lean
theorem Map.update_go_eq_self (m : Map β) (h : k ∉ m.keys)
    (i j : Nat) (hi : i ≤ j) (hj : j ≤ m.keys.size) :
    Map.update.go k v m i j hi hj = m := by
  fun_induction Map.update.go
```

- `fun_induction` gera 5 casos, um por ramo de `go`. Clicar em cada caso na
  Infoview. Fechar um por um com `· grind`, depois tudo de uma vez:
  `fun_induction Map.update.go <;> grind`.
- Truque: apagar a prova e escrever `by try?`. O Lean sugere exatamente
  `(fun_induction Map.update.go) <;> grind`. Clicar na sugestão.
- Fechar o teorema principal: `:= Map.update_go_eq_self m h ..`

Bingo: *tactic proofs*, *functional induction*, *explicit proof terms*.

### Se sobrar tempo

- **Incrementalidade**: pôr `sleep 10000` antes de um `grind` num dos casos; só
  aquele trecho fica laranja, o resto do arquivo continua verificado.
- **`termination_by?`** em `go`: o Lean mostra a medida que ele deduziu.
- **Ir para a definição** (`F12`) em `Nat`: abre `Prelude.lean`. O menu do
  botão direito tem "Search With Loogle…".
- **Loogle** no navegador: buscar `Array, "update"`. Se alguém perguntar sobre
  o `!`: buscar `getElem!` e mostrar que `a[i]!` exige `Inhabited` no tipo do
  elemento, para ter um valor a devolver quando o índice é inválido.
- **Notação**: `notation:max m "[" k " := " v "]" => Map.update k v m`
  e `#eval testMap[0 := 42]` (está no gabarito).

### Se atrasar

- Na etapa 4, pular os `_ _` e o `(by grind)` intermediário: ir direto ao
  auto-param.
- Na etapa 6, pular o `grind [Map.hSize]` e ir direto ao
  `attribute [grind =] Map.hSize`.
- Na etapa 7, pular os casos um a um: `fun_induction … <;> grind` direto, e
  mostrar o `try?`.
- Em último caso: abrir o gabarito e percorrer.

## Bingo completo

Lista de Joachim (`02_DemoChallenge.lean`), com a tradução. O slide "Bingo"
tem 16 destes.

| Em português | Termo original |
|---|---|
| lambdas anônimas | anonymous lambdas |
| terminação verificada automaticamente | automatic termination checking |
| automação com `grind` | automation with `grind` |
| parâmetros automáticos | auto-params |
| programação funcional básica | basic functional programming |
| sugestões clicáveis (várias) | clickable hints (multiple) |
| notação própria | custom notation |
| tipos dependentes | dependent types |
| notação `do` | do notation |
| notação `do` com retorno antecipado | do notation with early return |
| notação `do` com atualização mutável | do notation with mutable update |
| notação `do` com iteração paralela | do notation with parallel iteration |
| teste embutido | embedded test |
| avaliar código | evaluating code |
| termos de prova explícitos | explicit proof terms |
| indução funcional | functional induction |
| autocompletar nomes de funções | function name autocompletion |
| ir para a definição | go to definition |
| hover (informação ao passar o mouse) | hover |
| atualizações imutáveis | immutable updates |
| parâmetros implícitos com táticas automáticas | implicit parameters with auto-tactics |
| incrementalidade | incrementality |
| dicas embutidas no texto | inlay hints |
| inspecionar o estado do `grind` | inspecting grind states |
| argumentos nomeados | named function arguments |
| notação de ponto sobrecarregada | overloaded dot notation |
| verificação de provas em paralelo | parallel proof checking |
| sintaxe de construtor de estrutura | structure constructor syntax |
| provas com táticas | tactic proofs |
| dica de tipo | type hint |
| digitar unicode | unicode entry |
| dicas para identificador desconhecido | unknown identifier code hints |
| recursão bem fundada | well-founded recursion |

As linhas de `do` (*do notation*…) e as lambdas anônimas vêm de
`sumKeysUntil`, que está no repositório de Joachim mas não neste roteiro.
