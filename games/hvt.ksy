meta:
  id: hvt
  title: Havok-style texture (.hvt)
  file-extension: hvt
  endian: be
doc: |
  Havok-style `.hvt` texture (Aladdin Magic Racer `texWii/*.hvt`), followed by a
  plain Wii GX pixel chain without mips: `S3TW` = CMPR, `ARGB` = RGBA8, `G8A8` =
  IA8, `GRY8` = I8.
seq:
  - id: magic
    contents: ' IVH'
  - id: version
    type: u4
    doc: 2 or 6.
  - id: format_tag
    type: str
    size: 4
    encoding: ASCII
  - id: width
    type: u4
  - id: height
    type: u4
  - id: bits_per_pixel
    type: u4
  - id: pixels
    size-eos: true
