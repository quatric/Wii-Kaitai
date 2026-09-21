meta:
  id: smashpac
  endian: le
  title: Super Smash Bros. 4 animation container (.pac)
doc: |
  Super Smash Bros. 4 animation container bundling .omo skeletal and
  .mta material animations, per lib-smashpac.c (ported from
  KillzXGaming/Smash-Forge PAC.cs). Little-endian files start with
  "PACK"; big-endian ones start with "KCAP" instead (not covered by
  this definition). Distinct from the unrelated Nd Cube "PAC\0", HAL
  "ARC\0" and Mario Kart Arcade PAC containers elsewhere in this
  repo.
seq:
  - id: magic
    contents: "PACK"
  - id: reserved_04
    type: u4
  - id: num_entries
    type: s4
  - id: reserved_0c
    type: u4
  - id: name_offsets
    type: u4
    repeat: expr
    repeat-expr: num_entries
  - id: data_offsets
    type: u4
    repeat: expr
    repeat-expr: num_entries
  - id: sizes
    type: u4
    repeat: expr
    repeat-expr: num_entries
instances:
  names:
    type: str
    terminator: 0
    encoding: ASCII
    pos: name_offsets[_index]
    repeat: expr
    repeat-expr: num_entries
    io: _io
