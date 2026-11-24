meta:
  id: abrs
  title: Sega ABRS pack (.abr)
  file-extension: abr
  endian: le
doc: |
  Sega `ABRS` pack (Sakura Wars: So Long, My Love `*.abr`). Chunks (HMDL models
  and others) are walked via their own headers `{tag, u32 payload size,
  u32 header size}` from the data start and end with a trailer `EOFC`; only the
  table is modelled here.
seq:
  - id: magic
    contents: ABRS
  - id: len_payload
    type: u4
  - id: data_start
    type: u4
    doc: Table end, 16-byte aligned.
  - id: zero
    type: u4
  - id: crc
    type: u4
  - id: num_chunks
    type: u4
  - id: end_offset
    type: u4
  - id: data_start_repeat
    type: u4
  - id: table
    type: table_entry
    repeat: expr
    repeat-expr: num_chunks
types:
  table_entry:
    seq:
      - id: minus_one
        type: u4
        doc: 0xFFFFFFFF.
      - id: chunk_offset
        type: u4
        doc: Or 0; not needed to walk the chunks.
