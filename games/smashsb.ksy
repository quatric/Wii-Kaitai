meta:
  id: smashsb
  endian: le
  title: Super Smash Bros. 4 swing-bone table (SB)
doc: |
  Super Smash Bros. 4 swing-bone parameter table (" BWS" magic), per
  lib-smashvbn.c (ported from KillzXGaming/Smash-Forge VBN.cs class
  SB).
seq:
  - id: magic
    contents: [0x20, 0x42, 0x57, 0x53]
  - id: version
    type: u2
    doc: Always 5.
  - id: unknown_06
    type: u2
    doc: Always 1.
  - id: num_entries
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    doc: 140-byte entry.
    seq:
      - id: hash
        type: u4
      - id: params
        size: 32
      - id: swing_range
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: bone_hashes
        type: u4
        repeat: expr
        repeat-expr: 8
      - id: unknown_floats
        type: f4
        repeat: expr
        repeat-expr: 10
      - id: factor
        type: f4
      - id: unknown_ints
        type: s4
        repeat: expr
        repeat-expr: 3
