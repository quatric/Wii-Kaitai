meta:
  id: j3d_btp
  title: J3D texture pattern animation (.btp)
  file-extension: btp
  endian: be
doc: |
  J3D texture pattern animation `BTP` (`J3D1btp1` + `TPT1` chunk). Frame k of an
  entry shows `texture_index_table[first_index + k]`. Chunk offsets are relative
  to the chunk.
seq:
  - id: magic
    contents: 'J3D1btp1'
  - id: len_file
    type: u4
  - id: num_chunks
    type: u4
  - id: subversion
    size: 16
  - id: tpt1
    type: tpt1
types:
  tpt1:
    seq:
      - id: tag
        contents: TPT1
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
      - id: num_texture_indices
        type: u2
      - id: entries_offset
        type: u4
      - id: texture_index_table_offset
        type: u4
  entry:
    seq:
      - id: num_frames
        type: u2
      - id: first_index
        type: u2
      - id: texture_slot
        type: u1
      - id: pad
        size: 3
