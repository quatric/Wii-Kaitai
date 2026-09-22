meta:
  id: smashjtb
  endian: be
  title: Super Smash Bros. 4 joint table (JTB)
doc: |
  Super Smash Bros. 4 joint table (.jtb), per lib-smashvbn.c (ported
  from KillzXGaming/Smash-Forge JTB.cs). This is a VBN bone-index remap
  with two consecutive arrays of signed 16-bit joint indices, not one
  undifferentiated array. There is no magic or stored byte-order tag.

  nintoolbox recognizes a file only when its length is even, between 4
  and 0x40000 bytes, and exactly `4 + 2 * (size1 + size2)` under the
  selected byte order. It first tests the big-endian counts; if that
  length matches and the first count is at most 255, it selects big-
  endian. Otherwise it requires a matching little-endian interpretation.
  This schema exposes that same selection rule, but it does not validate
  the file-length condition itself. The two arrays correspond to the
  decoder's table1 and table2 output sections.
seq:
  - id: size1_be_probe
    type: u2be
    doc: First count interpreted big-endian for byte-order detection.
  - id: size2_be_probe
    type: u2be
    doc: Second count interpreted big-endian for byte-order detection.
  - id: tables
    type: joint_tables(use_le, size1, size2)
    doc: Two signed-index arrays using the selected byte order.
instances:
  use_le:
    value: size1_be_probe > 255 or 4 + (size1_be_probe + size2_be_probe) * 2 != _io.size
    doc: True when the reader would select the little-endian interpretation.
  size1:
    value: 'use_le ? ((size1_be_probe & 0xff) << 8) | (size1_be_probe >> 8) : size1_be_probe'
  size2:
    value: 'use_le ? ((size2_be_probe & 0xff) << 8) | (size2_be_probe >> 8) : size2_be_probe'
types:
  joint_tables:
    params:
      - id: is_le
        type: bool
      - id: count1
        type: u2
      - id: count2
        type: u2
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: table1
        type: s2
        repeat: expr
        repeat-expr: count1
        doc: First VBN joint-index remapping table.
      - id: table2
        type: s2
        repeat: expr
        repeat-expr: count2
        doc: Second VBN joint-index remapping table.
