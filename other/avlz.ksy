meta:
  id: avlz
  title: Sega AVLZ LZSS block
  endian: be
doc: |
  Sega's "AVLZ" compression block, as carried by Super Monkey Ball: Banana
  Blitz's ARCB archives (see `games/arcb.ksy`). The 12-byte header is followed
  by Okumura-style LZSS:

  * a 4096-byte ring buffer pre-filled with zeros; the write position starts at
    `0xfee`;
  * flag bytes are consumed least-significant bit first; `1` = literal byte
    (copied to the output and the ring), `0` = a two-byte match
    `{u8 pos_lo, u8 (pos_hi << 4) | (len - 3)}` with
    `pos = pos_lo | (pos_hi << 8)` and `len = (second & 0xf) + 3`.

  The stream is complete when `unpacked_size` bytes have been produced.
  `packed_size` counts the 12-byte header.
seq:
  - id: magic
    contents: 'AVLZ'
  - id: unpacked_size
    type: u4
  - id: packed_size
    type: u4
    doc: Includes the 12-byte header.
  - id: stream
    size: packed_size - 12
    doc: LZSS flag/literal/match stream.
