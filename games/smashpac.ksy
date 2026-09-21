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

  The detector accepts either byte order, limits the signed count to 100000,
  requires all three u32 tables to fit after the 16-byte header, requires each
  name offset to reach a NUL before EOF, and requires every data range to fit.
  nintoolbox rebuilds names followed by 16-byte-aligned member payloads.
seq:
  - id: magic
    contents: "PACK"
  - id: reserved_04
    type: u4
    doc: Unknown header word; canonical rebuilds emit zero.
  - id: num_entries
    type: s4
    doc: Number of entries and elements in each of the three following tables.
  - id: reserved_0c
    type: u4
    doc: Unknown header word; canonical rebuilds emit zero.
  - id: name_offsets
    type: u4
    repeat: expr
    repeat-expr: num_entries
    doc: Absolute NUL-terminated filename offsets.
  - id: data_offsets
    type: u4
    repeat: expr
    repeat-expr: num_entries
    doc: Absolute member payload offsets.
  - id: sizes
    type: u4
    repeat: expr
    repeat-expr: num_entries
    doc: Member payload byte lengths.
instances:
  names:
    type: str
    terminator: 0
    encoding: ASCII
    pos: name_offsets[_index]
    repeat: expr
    repeat-expr: num_entries
    io: _io
    doc: Member names resolved from the offset table.
