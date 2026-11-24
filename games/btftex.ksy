meta:
  id: btftex
  title: Famicom Wars VS .btf texture/font bundle
  file-extension: btf
  endian: be
doc: |
  {"FTBG", u32 size, u32 count (little endian)}, then chunks {"DXTG", u32
  chunk size (LE)}. Chunk body (BE): name[0x20], u32 width, u32 height, u32 1,
  u32 id, char format[8] (reversed right-aligned "A8R8G8B8", "I8", "IA4", "P4",
  "P8"), char palette format[8], a "PAL " block and a "PIM " block; GX pixel
  data are the last width * height * bpp bytes.
seq:
  - id: magic
    contents: FTBG
  - id: size
    type: u4le
  - id: count
    type: u4le
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: count
types:
  chunk:
    seq:
      - id: tag
        contents: DXTG
      - id: size
        type: u4le
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: width
        type: u4
      - id: height
        type: u4
      - id: one
        type: u4
      - id: id
        type: u4
      - id: format
        size: 8
      - id: palette_format
        size: 8
      - id: rest
        size: size - 8 - 0x20 - 16 - 16
