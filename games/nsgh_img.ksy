meta:
  id: nsgh_img
  title: Neversoft Guitar Hero (Wii) .img.ngc texture
  file-extension: img.ngc
  endian: be
doc: |
  Neversoft's `.img.ngc` texture from the Wii Guitar Hero games (3465 files of
  Guitar Hero: Smash Hits (USA) verified): a 0x20-byte header and one GX
  image. The GX format is 14 (CMPR) in every file seen. nintoolbox exports
  only the top mip level, as a TPL.
seq:
  - id: magic
    contents: [0x04, 0x20]
    doc: '`u2` 0x0420.'
  - id: unknown_02
    size: 8
  - id: log2_width
    type: u1
    doc: Offset 0x0a.
  - id: log2_height
    type: u1
    doc: Offset 0x0b.
  - id: unknown_0c
    type: u1
  - id: gx_format
    type: u1
    doc: Offset 0x0d. 14 = CMPR on every file seen.
  - id: unknown_0e
    size: 2
  - id: top_level_size
    type: u4
    doc: Offset 0x10. Byte size of the top mip level.
  - id: data_offset
    type: u4
    doc: Offset 0x14. Always 0x20.
  - id: reserved
    size: 8
  - id: image_data
    size-eos: true
    doc: GX image data; the first `top_level_size` bytes are the top mip level.
instances:
  width:
    value: 1 << log2_width
  height:
    value: 1 << log2_height
