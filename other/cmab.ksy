meta:
  id: cmab
  file-extension: cmab
  endian: le
  title: Grezzo 3DS CMAB material animation / texture bank
doc: |
  Grezzo's 3DS "CMAB" container, used by Ocarina of Time 3D and other
  Grezzo titles to hold material-animation data and an embedded PICA200
  texture table (`txpt`). Offsets are little-endian and are relative to
  bases held in the header.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid: '"cmab"'
  - id: unknown1
    size: 0x10
  - id: ofs_txpt_rel
    type: u4
    doc: Offset of the `txpt` block, added to `ofs_txpt_base` at 0x30.
  - id: ofs_name_table
    type: u4
  - id: data_base
    type: u4
  - id: unknown2
    size: 0x14
  - id: ofs_txpt_base
    type: u4
instances:
  txpt:
    io: _io
    pos: ofs_txpt_rel + ofs_txpt_base
    type: txpt_block
  name_table:
    io: _io
    pos: ofs_name_table
    type: name_table_block
types:
  txpt_block:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
        valid: '"txpt"'
      - id: texture_count
        type: u4
      - id: entry
        type: txpt_entry
        repeat: expr
        repeat-expr: texture_count
      - id: strt_magic
        type: str
        size: 4
        encoding: ASCII
        valid: '"strt"'
      - id: name_count
        type: u4
  txpt_entry:
    doc: One 0x18-byte embedded PICA texture record.
    seq:
      - id: pica_format
        type: u4
        enum: pica_format
      - id: unknown
        size: 8
      - id: width
        type: u2
      - id: height
        type: u2
      - id: ofs_data
        type: u4
        doc: Offset of the raw texel data, relative to `data_base`.
      - id: id
        type: u4
  name_table_block:
    seq:
      - id: entries_ofs_and_hash
        size: 8
enums:
  pica_format:
    0x14016752: rgba8
    0x14016754: rgb8
    0x80346752: rgba5551
    0x83636754: rgb565
    0x80336752: rgba4
    0x14016758: la8
    0x67606758: la4
    0x14016757: l8
    0x14016756: a8
    0x67616757: l4
    0x675a: etc1
    0x675b: etc1a4
