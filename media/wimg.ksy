meta:
  id: wimg
  endian: be
  title: CyberConnect2 WIMG texture (Wii)
doc: |
  CyberConnect2 ".wimg" texture (And-Kensaku / "Kanji Sonomama"
  family, Wii), per lib-wimg.h. GX-tiled pixel data is not detiled
  here; CI4/CI8 payloads are followed immediately by a straight
  RGBA8888 palette (16 or 256 entries).
seq:
  - id: magic
    contents: "WIMG"
    doc: CyberConnect2 WIMG signature.
  - id: header_size
    type: u4
    doc: Header size / data offset, always 0x20.
  - id: width
    type: u2
    doc: Texture width in pixels; the decoder accepts 1..4096.
  - id: height
    type: u2
    doc: Texture height in pixels; the decoder accepts 1..4096.
  - id: pixel_format
    type: u1
    enum: format_t
    doc: CI4, CI8, or tiled RGBA32 encoding selector.
  - id: sub_flags
    size: 3
    doc: Palette kind / mip count; unused by the reference decoder.
  - id: data_offset
    type: u4
    doc: Always 0x20.
  - id: data_size
    type: u4
    doc: 0 for format RGBA32.
  - id: reserved
    size: 8
    doc: Reserved header words at 0x18..0x1f; preserve them.
  - id: pixel_data
    size-eos: true
    doc: >-
      Container tail beginning at data_offset.  image_data and palette below
      expose exact logical spans; this view retains any producer-specific
      trailing bytes.
instances:
  index_data_size:
    value: "pixel_format == format_t::ci4 ? (width * height + 1) / 2 : pixel_format == format_t::ci8 ? width * height : ((width + 3) / 4) * ((height + 3) / 4) * 64"
    doc: >-
      Number of bytes consumed by the reference decoder before palette data:
      packed nibbles for CI4, one byte per CI8 index, or 4×4 RGBA32 tiles.
  image_data:
    pos: data_offset
    size: index_data_size
    doc: >-
      Exact encoded pixel/index stream.  RGBA32 tiles store 32 bytes of
      alpha/red pairs followed by 32 bytes of green/blue pairs.
  palette_entry_count:
    value: "pixel_format == format_t::ci4 ? 16 : pixel_format == format_t::ci8 ? 256 : 0"
    doc: Number of appended RGBA8888 palette entries for indexed formats.
  palette:
    pos: data_offset + index_data_size
    type: rgba8888
    repeat: expr
    repeat-expr: palette_entry_count
    if: palette_entry_count != 0
    doc: >-
      Palette immediately following the index stream.  Its entries are
      straight byte-order RGBA8888, not GX RGB5A3 or RGB565 values.
types:
  rgba8888:
    seq:
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1
      - id: alpha
        type: u1
enums:
  format_t:
    1: ci4
    2: ci8
    9: rgba32
