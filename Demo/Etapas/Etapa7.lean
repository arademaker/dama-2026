/-
Busca binária ao vivo, etapa 7 de 7: o arquivo como fica ao fim da etapa.
Adaptado do live demo de Joachim Breitner (Lean FRO):
https://github.com/nomeata/lean-highlights-tfp
Ver `ROTEIRO.md`.
-/

structure Map β where
  keys : Array Nat
  values : Array β
  hSize : keys.size = values.size

attribute [grind =] Map.hSize

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

theorem Map.update_go_eq_self (m : Map β) (h : k ∉ m.keys)
    (i j : Nat) (hi : i ≤ j) (hj : j ≤ m.keys.size) :
    Map.update.go k v m i j hi hj = m := by
  fun_induction Map.update.go <;> grind

theorem Map.update_eq_self (m : Map β) (h : k ∉ m.keys) :
    m.update k v = m :=
  Map.update_go_eq_self m h ..
