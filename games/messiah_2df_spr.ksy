meta:
  id: messiah_2df_spr
  title: Messiah-engine 2df sprite sheet (.spr)
  file-extension: spr
  endian: le
doc: |
  Messiah-engine `2df\0` sprite sheet (Gummy Bears). Version 11 layout: header,
  `u4 texture_count` at 0x108, and texture descriptors as the last 0x20-byte
  records before the pixel data; textures follow, each padded to 0x20.
  Descriptor: `{u4 0x10001, u4 mode, u4 end, u4 width, u4 height, u4 0, u4
  format, u4 size + 8}`. Pixels are GX RGBA8 (`size = w*h*4`) or RGB5A3 (`w*h*2`).
  Version-10 single-texture sheets (Pool Hall Pro) put the descriptor at 0x1d0
  and the data at 0x1f8 (format 0x1a = CMPR).
seq:
  - id: magic
    contents: ['2df', 0]
  - id: version
    type: u4
    doc: 10 or 11.
  - id: unknown_08
    type: u4
  - id: header
    size: 0x108 - 0x0c
  - id: texture_count
    type: u4
  - id: rest
    size-eos: true
types:
  texture_descriptor:
    seq:
      - id: marker
        type: u4
        doc: 0x10001.
      - id: mode
        type: u4
      - id: end
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: zero
        type: u4
      - id: format
        type: u4
      - id: size_plus_8
        type: u4
