meta:
  id: txg
  title: EA TXG texture group (Tiger Woods PGA Tour)
  endian: be
doc: |
  Chunks {tag, u32 size, data}: HEAD, TXHE (88-byte records), CLHE, TXDA
  (texture data). Record: name[16], four mip entries {u32 offset in TXDA,
  u16 blocks, u16 0xffff, u32 ?} at +0x10, u16 width, u16 height at +0x40,
  u8 GX format at +0x48 (14 CMPR, 5 RGB5A3, 0 I4).
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: data
        size: size - 8
        type:
          switch-on: tag
          cases:
            '"TXHE"': txhe
  txhe:
    seq:
      - id: records
        type: record
        repeat: eos
  record:
    seq:
      - id: name
        size: 16
        type: strz
        encoding: ASCII
      - id: mips
        type: mip
        repeat: expr
        repeat-expr: 4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: unk44
        size: 4
      - id: format
        type: u1
      - id: tail
        size: 88 - 0x49
  mip:
    seq:
      - id: offset
        type: u4
      - id: blocks
        type: u2
      - id: ffff
        type: u2
      - id: unk
        type: u4
