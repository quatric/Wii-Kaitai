meta:
  id: j3d_bpk
  title: J3D material colour animation (.bpk)
  file-extension: bpk
  endian: be
doc: |
  J3D material colour animation `BPK` (`J3D1bpk1` + `PAK1` chunk). Every entry
  is four tracks (R G B A) of `{u16 key count, u16 table index, u16 tangent
  type}`; a single key is a constant, otherwise keys are `{time, value, tangent
  in[, out]}` (3 or 4 values when the tangent type is 1). Colour components are
  0..255. Chunk offsets are relative to the chunk.
seq:
  - id: magic
    contents: 'J3D1bpk1'
  - id: len_file
    type: u4
  - id: num_chunks
    type: u4
  - id: subversion
    size: 16
  - id: pak1
    type: pak1
types:
  pak1:
    seq:
      - id: tag
        contents: PAK1
      - id: len_chunk
        type: u4
      - id: loop_mode
        type: u1
      - id: pad
        size: 1
      - id: duration
        type: u2
      - id: num_entries
        type: u2
      - id: len_r_table
        type: u2
      - id: len_g_table
        type: u2
      - id: len_b_table
        type: u2
      - id: len_a_table
        type: u2
      - id: pad2
        size: 2
      - id: entries_offset
        type: u4
      - id: reserved
        size: 8
      - id: r_table_offset
        type: u4
      - id: g_table_offset
        type: u4
      - id: b_table_offset
        type: u4
      - id: a_table_offset
        type: u4
