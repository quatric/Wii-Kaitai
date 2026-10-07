meta:
  id: blue_castle_big
  title: Blue Castle Games .big archive (The Bigs, Wii)
  file-extension: big
  endian: le
doc: |
  Blue Castle Games' `.big` archives (The Bigs, The Bigs 2, Wii). No public
  documentation exists; the layout below was worked out from the 836
  archives on the retail disc of The Bigs (USA), and every one of them
  satisfies it exactly (header size field == file size, every entry inside
  the file). Not the Electronic Arts `BIGF` archive, which is big-endian.

  Members are stored uncompressed. Nested archives are ordinary `.big` files.
  Audio members are `.dspi`; see `blue_castle_dspi.ksy`.
seq:
  - id: magic
    contents: [0x04, 0x03, 0x02, 0x01]
    doc: '`u4` 0x01020304.'
  - id: data_start
    type: u4
    doc: Offset of the first member's data.
  - id: file_size
    type: u4
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: Entry table offset (0x18 seen).
  - id: names_offset
    type: u4
    doc: NUL-separated name table offset.
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name_offset
        type: u4
        doc: Absolute.
      - id: size
        type: u4
      - id: offset
        type: u4
        doc: Absolute.
      - id: kind
        type: u4
        enum: kind
      - id: zero
        type: u4
    instances:
      name:
        pos: name_offset
        type: strz
        encoding: ASCII
        io: _root._io
      body:
        pos: offset
        size: size
        io: _root._io
enums:
  kind:
    4: nested_archive
    32: model_blob
    256: nested_archive_256
    2048: aligned_audio
