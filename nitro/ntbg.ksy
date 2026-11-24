meta:
  id: ntbg
  title: Game Freak Nitro background (.5bg)
  file-extension: 5bg
  endian: le
doc: |
  Game Freak Nitro background (`NTBG` / `.5bg`, Looksley's Line Up). Chunks:
  `PALT` = `{u32 n, n x BGR555}`; `BGDT` = `{u8 depth (0 = 4 bpp with 16-colour
  sub-palettes, 1 = 8 bpp), u8 0xFF, u16 2, u32 screen bytes, u16 w, u16 h
  (tiles), u16 w, u16 h, u32 tile bytes}` then a 32-wide NDS text-BG screen map
  (tile 10 bits, h/v flip, 4-bit palette) and the 8x8 tiles. `DFPL` (default
  palette?) is ignored.
seq:
  - id: magic
    contents: NTBG
  - id: bom
    contents: [0xff, 0xfe]
  - id: version
    type: u2
    doc: 0x100.
  - id: len_file
    type: u4
  - id: header_size
    type: u2
    doc: 0x10.
  - id: num_chunks
    type: u2
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: num_chunks
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_chunk
        type: u4
        doc: Includes the 8-byte head.
      - id: body
        size: len_chunk - 8
