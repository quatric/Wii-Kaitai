meta:
  id: sonicex
  title: Sonic Team _Ex pack
  endian: be
doc: |
  Sonic and the Secret Rings `Now/_Ex1xx`. A member is raw or wrapped as
  "compress v1.0\0" + u16 0x0040 + u32le size + Okumura LZSS stream at 0x14
  (zero-filled 4096-byte ring, write position 0xfee, LSB-first, 1 = literal).
seq:
  - id: one
    type: u4
  - id: count
    type: u1
  - id: pad
    size: 3
  - id: id
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
    doc: The first one is the table end rounded up to 0x20; the last member ends at EOF.
