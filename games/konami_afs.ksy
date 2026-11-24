meta:
  id: konami_afs
  title: Konami afs container (Pro Evolution Soccer 2012, Wii)
  endian: be
doc: |
  Konami `afs` container (not the CRI `AFS\0` archive). `count + 1` offsets,
  relative to 0x20, follow the count at 0x20; the last offset is the end of
  the last member. A member is stored as is (SDHS sound data, PACS packs, ...)
  or wrapped: `{u8 4, 3 flag bytes, u32 packed size, u32 unpacked size,
  20 zero bytes}` followed by a zlib stream (see `packed_member`).
seq:
  - id: type
    type: u1
    doc: 4.
  - id: flags
    size: 3
  - id: len_total
    type: u4
  - id: reserved
    size: 0x18
  - id: num_members
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: num_members + 1
    doc: Relative to 0x20.
types:
  packed_member:
    seq:
      - id: type
        type: u1
        doc: 4.
      - id: flags
        size: 3
      - id: len_packed
        type: u4
      - id: len_unpacked
        type: u4
      - id: zeros
        size: 20
      - id: zlib_stream
        size: len_packed
