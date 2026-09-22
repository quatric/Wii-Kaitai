meta:
  id: smashmoi
  endian: be
  title: Super Smash Bros. 4 model index (MOI)
doc: |
  Super Smash Bros. 4 model index (.moi), per lib-smashvbn.c (ported
  from KillzXGaming/Smash-Forge MOI.cs). Each record leads with a
  name offset that is absolute in the file, not relative to a single
  name-table base. The seven following words in an ordinary entry and
  the second word in an "other" entry are printed as signed values;
  the decoder does not assign further meanings to them.

  nintoolbox requires the fixed header words at 0x08, 0x0c, 0x10,
  and 0x14 to be 0x30, 0x20, 8, and 0x30 respectively. It accepts at
  most 100000 entries of each kind, checks that both fixed-stride tables
  fit, and requires every referenced name to be NUL-terminated within
  EOF. These checks distinguish this headerless-by-magic format from
  arbitrary binary data.
seq:
  - id: num_entries
    type: u4
  - id: num_other
    type: u4
  - id: entries_start
    type: u4
    valid:
      eq: 0x30
    doc: Fixed absolute start of the 32-byte entry table.
  - id: entry_stride
    type: u4
    valid:
      eq: 0x20
    doc: Fixed 32-byte stride of ordinary entries.
  - id: other_stride
    type: u4
    valid:
      eq: 8
    doc: Fixed eight-byte stride of other entries.
  - id: unknown_14
    type: u4
    valid:
      eq: 0x30
    doc: Header word required to equal 0x30; purpose otherwise unknown.
  - id: other_start
    type: u4
instances:
  entries:
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
    pos: entries_start
  others:
    type: other_t
    repeat: expr
    repeat-expr: num_other
    pos: other_start
types:
  entry_t:
    doc: 32-byte (8 u32) record, first word is a name-table offset.
    seq:
      - id: name_offset
        type: u4
        doc: Absolute file offset of a NUL-terminated entry name.
      - id: fields
        type: s4
        repeat: expr
        repeat-expr: 7
        doc: Seven signed values printed without further interpretation.
    instances:
      name:
        io: _root._io
        pos: name_offset
        type: str
        encoding: UTF-8
        terminator: 0
  other_t:
    doc: 8-byte (2 u32) record, first word is a name-table offset.
    seq:
      - id: name_offset
        type: u4
        doc: Absolute file offset of a NUL-terminated other-entry name.
      - id: value
        type: s4
        doc: Signed value reported by the decoder.
    instances:
      name:
        io: _root._io
        pos: name_offset
        type: str
        encoding: UTF-8
        terminator: 0
