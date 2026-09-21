meta:
  id: smashjtb
  endian: be
  title: Super Smash Bros. 4 joint table (JTB)
doc: |
  Super Smash Bros. 4 joint table (.jtb), per lib-smashvbn.c (ported
  from KillzXGaming/Smash-Forge JTB.cs). No magic; big-endian, or
  little-endian if the first count exceeds 255.
seq:
  - id: size1
    type: u2
  - id: size2
    type: u2
  - id: joint_indices
    type: s2
    repeat: expr
    repeat-expr: size1 + size2
