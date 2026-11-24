meta:
  id: sedb
  title: Square Enix SEDB resource container (Dragon Quest X, Wii)
  file-extension: rps
  endian: le
doc: |
  Header fields are little endian although the Wii payload that follows is big
  endian. RES (.rps) index: 0x20 u32 n_records, 0x24 hint, 0x28 n_records - 1,
  0x2c own resource type byte-reversed ("spr" = "rps"), 0x30 n_records * {u32
  index, u32 offset, u32 size, u32 1}; offsets relative to the end of the table
  (0x30 + 16 * n). The last three records are metadata (n-2 type table, n-1 name
  table n * char[16]). shd: 0x20 "SHD" header then chunks {tag[4], u32 0, u32
  size, ...} ("WMAT", "PRAM"). PRAM (BE): chunk+0x18 u32 n, 5 section words, n
  record offsets, n name offsets (relative to chunk+0x10); record 0x20 bytes {u8
  flag, u8 1, u8 component count, 13 bytes, f32[count] at +0x10}.
seq:
  - id: magic
    contents: SEDB
  - id: type
    size: 4
    type: strz
    encoding: ASCII
    doc: '"RES ", "txb", "shd", "PHB", "lyb" (NUL padded).'
  - id: version
    type: u4
  - id: flags_a
    type: u1
  - id: flags_b
    type: u1
  - id: header_size
    type: u2
    doc: 0x20 (0x30 for "lyb").
  - id: file_size
    type: u4
  - id: unk14
    size: 4
  - id: build_time
    type: u4
    doc: Unix time.
  - id: unk1c
    size: 4
  - id: body
    type: res_body
    if: type == "RES "
types:
  res_body:
    seq:
      - id: record_count
        type: u4
      - id: offset_hint
        type: u4
      - id: count_minus_one
        type: u4
      - id: own_type
        size: 4
      - id: records
        type: record
        repeat: expr
        repeat-expr: record_count
  record:
    seq:
      - id: index
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: one
        type: u4
