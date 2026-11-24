meta:
  id: j3d_brk
  title: J3D colour register animation (.brk)
  file-extension: brk
  endian: be
doc: |
  J3D colour register animation `BRK` (`J3D1brk1` + `TRK1` chunk; layout
  checked against the JStudio sources). A 0x1C-byte entry is four tracks (R G B
  A) of `{u16 key count, u16 table index, u16 tangent type}` plus a u8 colour id;
  a single key is a constant, otherwise keys are `{time, value, tangent in[,
  out]}`. Konst entries are numbered after the register entries; components are
  0..255. Chunk offsets are relative to the chunk.
seq:
  - id: magic
    contents: 'J3D1brk1'
  - id: len_file
    type: u4
  - id: num_chunks
    type: u4
  - id: subversion
    size: 16
  - id: trk1
    type: trk1
types:
  trk1:
    seq:
      - id: tag
        contents: TRK1
      - id: len_chunk
        type: u4
      - id: loop_mode
        type: u1
      - id: pad
        size: 1
      - id: duration
        type: u2
      - id: num_register_entries
        type: u2
      - id: num_konst_entries
        type: u2
      - id: len_register_tables
        type: u2
        repeat: expr
        repeat-expr: 4
        doc: R, G, B, A.
      - id: len_konst_tables
        type: u2
        repeat: expr
        repeat-expr: 4
        doc: R, G, B, A.
      - id: register_entries_offset
        type: u4
      - id: konst_entries_offset
        type: u4
      - id: reserved
        size: 0x10
      - id: register_table_offsets
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: konst_table_offsets
        type: u4
        repeat: expr
        repeat-expr: 4
  entry:
    seq:
      - id: tracks
        type: track
        repeat: expr
        repeat-expr: 4
      - id: color_id
        type: u1
      - id: pad
        size: 3
  track:
    seq:
      - id: num_keys
        type: u2
      - id: table_index
        type: u2
      - id: tangent_type
        type: u2
