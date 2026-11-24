meta:
  id: fsar
  title: Freestyle Games FSAR archive (.FAR)
  file-extension: far
  endian: be
doc: |
  Freestyle Games `FSAR` archive (DJ Hero, Wii `FAR/*.FAR`). Entries are
  0x120 bytes each; `data_offset` is where the file data begins and each
  entry's offset is relative to it. Paths are backslash separated, NUL padded.
seq:
  - id: magic
    contents: FSAR
  - id: version
    type: u4
    doc: 2.
  - id: data_offset
    type: u4
  - id: num_entries
    type: u4
  - id: padding
    size: 16
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: path
        size: 0x100
        type: strz
        encoding: ASCII
      - id: zero0
        type: u4
      - id: len_unpacked
        type: u4
      - id: zero1
        type: u4
      - id: len_packed
        type: u4
      - id: zero2
        type: u4
      - id: offset
        type: u4
        doc: Relative to the file data.
      - id: method
        type: u4
        doc: 2 = zlib.
      - id: zero3
        type: u4
    instances:
      data:
        pos: _root.data_offset + offset
        io: _root._io
        size: len_packed
