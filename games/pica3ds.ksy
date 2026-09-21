meta:
  id: pica3ds
  title: Nintendo 3DS PICA200 texture wrappers (BTGA/LGA, STEX, DMPBM, CMB "tex ")
  license: CC0-1.0

doc: |
  Four small Nintendo 3DS texture-wrapper formats that all carry the same
  PICA200 8x8-Morton-tiled GPU pixel data with a different tiny header:
  BTGA (aka LGA), STEX, DMPBM, and the "tex " chunk embedded in a CMB model.
  This file has no single root type -- each format is a distinct standalone
  container -- so it defines one type per format for use with `ksv -t
  <type>` or an importing .ksy's own root selection.

  Reference: nintoolbox project/src/lib-pica3ds.c
  (DecodeBTGA_RGBA / DecodeSTEX_RGBA / DecodeDMPBM_RGBA /
  DecodeCMBTexture_RGBA).

seq: []

types:
  btga:
    doc: |
      Fixed-size 0x38-byte header, pixel data follows at a fixed offset
      0x38. "kind" selects which pair of offsets carries width/height/format:
      kind==1 uses 0x0c/0x0e/0x14; kind==0x400 uses 0x18/0x1a/0x20. Any other
      kind is rejected by the reference decoder.
    seq:
      - id: kind
        type: u4le
        enum: btga_kind
      - id: header_rest
        size: 0x34
      - id: pixel_data
        size-eos: true
    instances:
      width:
        pos: 'kind == btga_kind::short_header ? 0x0c : 0x18'
        type: u2le
      height:
        pos: 'kind == btga_kind::short_header ? 0x0e : 0x1a'
        type: u2le
      pica_format:
        pos: 'kind == btga_kind::short_header ? 0x14 : 0x20'
        type: u2le
    enums:
      btga_kind:
        1: short_header
        0x400: long_header

  stex:
    seq:
      - id: magic
        contents: "STEX"
      - id: reserved1
        size: 8
      - id: width
        type: u4le
      - id: height
        type: u4le
      - id: gl_type
        type: u4le
      - id: gl_format
        type: u4le
      - id: image_size
        type: u4le
      - id: image_offset
        type: u4le
        doc: Either 0x20 (short header) or 0x80 (long header); anything else falls back to 0x20.
      - id: padding
        size: image_offset_actual - 0x20
        if: image_offset_actual > 0x20
      - id: pixel_data
        size-eos: true
    instances:
      image_offset_actual:
        value: 'image_offset == 0x80 ? 0x80 : 0x20'

  dmpbm:
    seq:
      - id: magic
        contents: "DMPBM"
      - id: format
        type: u1
        enum: dmpbm_format
      - id: width
        type: u4le
      - id: height
        type: u4le
      - id: extra_lut
        size: 512
        if: 'format == dmpbm_format::rgba5551_indexed'
      - id: pixel_data
        size-eos: true
    enums:
      dmpbm_format:
        0: rgb565
        1: i8
        2: ia4
        4: rgba5551_indexed

  cmb_tex_entry:
    doc: One entry of a CMB model's "tex " chunk, 36 bytes.
    seq:
      - id: data_size
        type: u4le
      - id: unknown1
        size: 4
      - id: width
        type: u2le
      - id: height
        type: u2le
      - id: gl_format
        type: u2le
      - id: gl_type
        type: u2le
      - id: data_offset
        type: u4le
        doc: Relative to the CMB's first raw-data slot.
      - id: unknown2
        size: 16
