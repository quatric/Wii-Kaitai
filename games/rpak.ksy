meta:
  id: rpak
  endian: be
  title: Retro Studios PAK archive (DK Country Returns, Wii)
doc: |
  Retro Studios ".pak" archive, per lib-rpak.c/.h. Only the fields
  needed to recover entries are modeled: a 0x80-byte header prelude,
  an STRG section (length known, contents not modeled), an RSHD
  entry table, then the entry payloads. Payloads whose `compressed`
  flag is set are CMPD/zlib-wrapped -- see `cmpd.ksy`.
seq:
  - id: header
    size: 0x48
  - id: strg_length
    type: u4
  - id: unknown_4c
    size: 4
  - id: rshd_length
    type: u4
  - id: unknown_54
    size: 0x80 - 0x54
  - id: strg
    size: strg_length
  - id: rshd
    type: rshd_t
    size: rshd_length
instances:
  data_base:
    value: 0x80 + strg_length + rshd_length
types:
  rshd_t:
    seq:
      - id: num_entries
        type: u4
      - id: entries
        type: entry_t
        repeat: expr
        repeat-expr: num_entries
  entry_t:
    seq:
      - id: compressed
        type: u4
      - id: magic
        type: u4
      - id: id_hi
        type: u4
      - id: id_lo
        type: u4
      - id: data_length
        type: u4
      - id: data_ptr
        type: u4
    instances:
      body:
        pos: _root.data_base + data_ptr
        size: data_length
        io: _root._io
