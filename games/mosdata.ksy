meta:
  id: mosdata
  title: Starbreeze MOS DATAFILE2.0 container (compiledtextures.xtc)
  file-extension: xtc
  endian: le
doc: |
  Enclave Shadows of Twilight (Wii). 0x30-byte file header, then texture
  records {u32 mip offsets[n]} pointing at 0x28-byte headers {0x200, 0x5000
  (GX CMPR), size+0x10, w, h, 0x20/0x800, 0, data size, 0, 0x10} + pixels,
  largest mip first. Records are located by scanning; other record kinds exist.
seq:
  - id: header
    size: 0x30
types:
  texture_header:
    seq:
      - id: x200
        type: u4
      - id: format
        type: u4
        doc: 0x5000 = GX CMPR.
      - id: size_plus_0x10
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: x20_or_x800
        type: u4
      - id: zero0
        type: u4
      - id: data_size
        type: u4
      - id: zero1
        type: u4
      - id: x10
        type: u4
