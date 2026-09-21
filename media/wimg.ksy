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
  - id: header_size
    type: u4
    doc: Header size / data offset, always 0x20.
  - id: width
    type: u2
  - id: height
    type: u2
  - id: pixel_format
    type: u1
    enum: format_t
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
  - id: pixel_data
    size-eos: true
enums:
  format_t:
    1: ci4
    2: ci8
    9: rgba32
