meta:
  id: smashsb
  endian: le
  title: Super Smash Bros. 4 swing-bone table (SB)
doc: |
  Super Smash Bros. 4 swing-bone parameter table (" BWS" magic), per
  lib-smashvbn.c (ported from KillzXGaming/Smash-Forge VBN.cs class
  SB). Each 140-byte entry has a 24-byte opaque parameter block after
  its hash, then six range floats: min/max for rotation X, Y, and Z.
  The eight following hashes reference chained bones. Ten more floats,
  one factor, and three signed words complete the entry; nintoolbox
  prints the ranges and factor but does not assign meanings to all
  remaining values.

  Detection requires the " BWS" magic, at least 12 bytes, an entry
  count at most 100000, and file length exactly `12 + 140 * count`.
  The decoder reports the two 16-bit header words as a version pair,
  but does not actually require values 5 and 1.
seq:
  - id: magic
    contents: [0x20, 0x42, 0x57, 0x53]
  - id: version
    type: u2
    doc: Usually 5; decoder reports but does not validate it.
  - id: unknown_06
    type: u2
    doc: Usually 1; decoder reports it as second version component.
  - id: num_entries
    type: u4
    doc: Number of fixed 140-byte swing-bone records.
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
        doc: Identifier hash for this swing bone.
      - id: params
        size: 24
        doc: Opaque parameter bytes preceding the rotation ranges.
      - id: swing_range
        type: f4
        repeat: expr
        repeat-expr: 6
        doc: Rotation X min/max, Y min/max, and Z min/max.
      - id: bone_hashes
        type: u4
        repeat: expr
        repeat-expr: 8
        doc: Hashes of up to eight chained or related bones.
      - id: unknown_floats
        type: f4
        repeat: expr
        repeat-expr: 10
      - id: factor
        type: f4
        doc: Swing factor reported by nintoolbox.
      - id: unknown_ints
        type: s4
        repeat: expr
        repeat-expr: 3
