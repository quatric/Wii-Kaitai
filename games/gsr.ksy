meta:
  id: gsr
  title: Pangya gsr resource (.gsr textures)
  file-extension: gsr
  endian: be
doc: |
  {u32 0x20, "ffrg" "\0rsg", u32 file size, u32 ?, u32 chunk count, ...}; 16-byte
  chunk headers from 0x20 {tag stored reversed ("\0xet" = "tex", "dxet" = "texd",
  "\0lap" = "pal", "dlap" = "pald"), u32 a, u32 b, u32 c}. "tex": a records of b
  bytes at c {u32 format (0x80000000 | GX format: 6 RGBA8, 9 C8, 0xe CMPR), u32
  width, height, levels, level-0 size, 0}. "texd": a bytes of pixel data at c.
  "pal": records {u32 format 6, u32 entries, 0}; "pald": 32-bit ARGB palette.
seq:
  - id: x20
    type: u4
  - id: magic
    size: 8
  - id: file_size
    type: u4
  - id: unk
    type: u4
  - id: chunk_count
    type: u4
  - id: pad
    size: 0x20 - 0x18
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: chunk_count
types:
  chunk:
    seq:
      - id: tag
        size: 4
      - id: a
        type: u4
      - id: b
        type: u4
      - id: c
        type: u4
  tex_record:
    seq:
      - id: format
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: levels
        type: u4
      - id: level0_size
        type: u4
      - id: zero
        type: u4
