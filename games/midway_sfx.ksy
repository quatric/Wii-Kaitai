meta:
  id: midway_sfx
  title: Midway sound-effect bank (.sfx)
  file-extension: sfx
  endian: be
doc: |
  Midway sound-effect bank (members of TNA Impact! WADs). A sample record is a
  0x60-byte GameCube DSP-ADPCM header followed by its ADPCM data, padded to 16
  bytes; records follow each other from `first_sample_offset`. NUL-terminated
  names follow the entry table.
seq:
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: constant_0xc
    type: u4
  - id: first_sample_offset
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: zero0
        type: u4
      - id: zero1
        type: u4
      - id: len_record
        type: u4
      - id: name_offset
        type: u4
      - id: end_offset
        type: u4
    instances:
      name:
        pos: name_offset
        io: _root._io
        type: strz
        encoding: ASCII
