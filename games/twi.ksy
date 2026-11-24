meta:
  id: twi
  title: Exient TWI texture (NFS Hot Pursuit Wii)
  file-extension: twi
  endian: be
seq:
  - id: magic
    contents: ["TWI", 0]
  - id: width
    type: u4
  - id: height
    type: u4
  - id: mip_levels
    type: u4
  - id: format
    type: u4
    doc: 0 IA8, 3 RGBA8, 4 C4, 5 C8, 251 CMPR.
  - id: paletted_marker
    type: u4
    doc: 0xfa for the paletted formats.
  - id: palette_size
    type: u4
  - id: data_size
    type: u4
    doc: All mip levels, excluding the palette.
  - id: palette
    size: palette_size
    doc: RGB5A3 entries (paletted formats only).
  - id: data
    size: data_size
    doc: GX tiled, largest level first.
