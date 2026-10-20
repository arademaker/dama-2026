/-
# Busca binária ao vivo: o gabarito

Adaptado do live demo "Lean Highlights" de Joachim Breitner (Lean FRO):
https://github.com/nomeata/lean-highlights-tfp (`Highlights/03_BinSearch.lean`).
A ideia, o exemplo e a sequência da demonstração são dele.

Este arquivo é o ponto de chegada do roteiro em `Demo/Roteiro.md`, na
ordem em que Joachim escreve o código ao vivo. Difere um pouco da versão
final do repositório dele: lá, `go` só tem o parâmetro `hj`, calcula `mid`
antes do caso base e grava em `mid`.

Rede de segurança: se o arquivo ao vivo (`Demo/BinSearchLive.lean`) se
perder, abrir este. Conferido com o toolchain deste projeto por `make demo`.
-/

-- Etapa 1: a estrutura. `hSize` só aparece na etapa 6.
structure Map β where
  keys : Array Nat
  values : Array β
  hSize : keys.size = values.size

-- Etapa 6: o invariante vira uma regra do `grind`.
attribute [grind =] Map.hSize

-- Etapas 2 a 6: a busca binária.
def Map.update (k : Nat) (v : β) (m : Map β) : Map β :=
  go 0 m.keys.size
where
  go (i j : Nat) (hi : i ≤ j := by grind) (hj : j ≤ m.keys.size := by grind) :=
    if _ : i ≥ j then
      m
    else
      if _ : i + 1 = j then
        if m.keys[i] = k then
          { m with values := m.values.set i v (h := by grind)
                   hSize := by grind }
        else
          m
      else
        let mid := (i + j)/2
        let k' := m.keys[mid]
        if k < k' then
          go i mid
        else
          go mid j

-- Etapa 3: testes embutidos.
def testMap : Map Nat where
  keys := #[1,3,5,7]
  values := #[1,3,5,7]
  hSize := rfl

/-- info: { keys := #[1, 3, 5, 7], values := #[1, 42, 5, 7], hSize := _ } -/
#guard_msgs in
#eval testMap.update 3 42

/-- info: { keys := #[1, 3, 5, 7], values := #[1, 3, 5, 7], hSize := _ } -/
#guard_msgs in
#eval testMap.update 4 42

-- Etapa 7: a prova.
theorem Map.update_go_eq_self (m : Map β) (h : k ∉ m.keys)
    (i j : Nat) (hi : i ≤ j) (hj : j ≤ m.keys.size) :
    Map.update.go k v m i j hi hj = m := by
  fun_induction Map.update.go <;> grind

theorem Map.update_eq_self (m : Map β) (h : k ∉ m.keys) :
    m.update k v = m :=
  Map.update_go_eq_self m h ..

-- Extra, se sobrar tempo (está na versão final do repositório de Joachim).
notation:max m "[" k " := " v "]" => Map.update k v m

/-- info: { keys := #[1, 3, 5, 7], values := #[1, 3, 5, 7], hSize := _ } -/
#guard_msgs in
#eval testMap[0 := 42]
