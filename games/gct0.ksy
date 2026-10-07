meta:
  id: gct0
  title: Grasshopper Manufacture GCT0 texture
  file-extension: bin
  endian: be
doc: |
  Grasshopper Manufacture "GCT0" texture (No More Heroes 1 / 2 `.BIN`): a
  0x40-byte header followed by plain GX pixel data. Mip levels, when present,
  are ignored by nintoolbox (only the base level is decoded).
seq:
  - id: magic
    contents: 'GCT0'
  - id: gx_format
    type: u4
    doc: GX texture format (14 = CMPR).
  - id: width
    type: u2
  - id: height
    type: u2
  - id: header_rest
    size: 0x40 - 12
  - id: pixel_data
    size-eos: true
