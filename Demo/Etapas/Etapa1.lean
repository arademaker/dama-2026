/-
Busca binária ao vivo, etapa 1 de 7: o arquivo como fica ao fim da etapa.
Adaptado do live demo de Joachim Breitner (Lean FRO):
https://github.com/nomeata/lean-highlights-tfp
Ver `Demo/Roteiro.md`.
-/

structure Map β where
  keys : Array Nat
  values : Array β
