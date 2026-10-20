/-
Busca binária ao vivo, etapa 2 de 7: o arquivo como fica ao fim da etapa.
Adaptado do live demo de Joachim Breitner (Lean FRO):
https://github.com/nomeata/lean-highlights-tfp
Ver `Demo/Roteiro.md`.
-/

structure Map β where
  keys : Array Nat
  values : Array β

def Map.update (k : Nat) (v : β) (m : Map β) : Map β :=
  go 0 m.keys.size
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

def testMap : Map Nat where
  keys := #[1,3,5,7]
  values := #[1,3,5,7]

#eval testMap.update 3 42
