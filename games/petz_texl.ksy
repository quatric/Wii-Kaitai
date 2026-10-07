meta:
  id: petz_texl
  title: Petz engine TEXL texture
  file-extension: texl
  endian: be
doc: |
  Petz-engine "TEXL" texture (Cranium Kabookii and relatives): a 0x19-byte
  header, raw GX pixel data and an 8-byte trailer. The pixel format is not
  stored: nintoolbox infers it from the body length (`file size - 0x19 - 8`) for
  a `w x h` image with both dimensions multiples of 8:

  * `w * h / 2` bytes -- CMPR (4 bpp);
  * `w * h` bytes -- CMPR colour plane followed by an I4 alpha plane (the
    `_atxl` textures);
  * `w * h * 4` bytes -- RGBA8.
seq:
  - id: magic
    contents: 'TEXL'
  - id: version
    type: u4
  - id: zero
    type: u4
  - id: format
    type: u4
    doc: Seen as 0.
  - id: width
    type: u2
  - id: height
    type: u2
  - id: unknown_14
    type: u4
  - id: unknown_18
    type: u1
  - id: body
    size: _io.size - 0x19 - 8
  - id: trailer
    size: 8
