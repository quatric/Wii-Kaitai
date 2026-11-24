meta:
  id: sega_mscr
  title: SEGA MSCR script binary (.msX)
  endian: le
doc: |
  SEGA `MSCR` script binaries (Sakura Wars: So Long, My Love `*.msX`). Flag 0x400
  = compressed: then `u32 unpacked size, u32 0x8000, 8 x 0xFF` and the stream at
  `header size + 0x10`. The stream is a byte LZ with every byte and flag bit
  inverted ("Melt"): flags are read LSB first from an inverted byte; flag 1 =
  literal; else flag 1 = long match `{b0, b1, (b2)}` (len = b0 & 7, 0 = b2 + 1 else
  + 2; offset = `b1 * 0x20 + (b0 >> 3) - 0x2000`, both 0 ends), flag 0 = short
  match (2 flag bits = length - 2, one byte offset - 0x100). The window is 8 KiB.
seq:
  - id: magic
    contents: MSCR
  - id: len_payload
    type: u4
  - id: header_size
    type: u4
    doc: 0x20 (0x10 in two files, without the hash).
  - id: flags
    type: u4
    doc: 0x400 = compressed.
  - id: hash
    size: 16
    if: header_size == 0x20
