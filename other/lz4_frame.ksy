meta:
  id: lz4_frame
  endian: le
  file-extension: lz4
doc: |
  LZ4 Frame format, as used via lib-lz4.c/.h (a thin wrapper around the
  standard liblz4/lz4frame library; magic 0x184D2204). Only the frame
  header is modeled here -- the block stream that follows is a
  sequence of independently-sized (and optionally checksummed) LZ4
  block-format spans whose exact framing depends on flags this
  definition does not decode further.
seq:
  - id: magic
    contents: [0x04, 0x22, 0x4d, 0x18]
  - id: flg
    type: flg_byte
  - id: bd
    type: bd_byte
  - id: content_size
    type: u8
    if: flg.content_size_flag
  - id: dict_id
    type: u4
    if: flg.dict_id_flag
  - id: header_checksum
    type: u1
  - id: blocks
    size-eos: true
    doc: |
      Sequence of LZ4 blocks (each a u4 size-with-compressed-flag
      followed by that many bytes, optional per-block checksum, and a
      final zero-size u4 end marker), not decoded further here.
types:
  flg_byte:
    seq:
      - id: version
        type: b2
      - id: block_independence_flag
        type: b1
      - id: block_checksum_flag
        type: b1
      - id: content_size_flag
        type: b1
      - id: content_checksum_flag
        type: b1
      - id: reserved_0
        type: b1
      - id: dict_id_flag
        type: b1
  bd_byte:
    seq:
      - id: reserved_0
        type: b1
      - id: block_max_size
        type: b3
        enum: block_max_size
      - id: reserved_1
        type: b4
enums:
  block_max_size:
    4: max_64kb
    5: max_256kb
    6: max_1mb
    7: max_4mb
