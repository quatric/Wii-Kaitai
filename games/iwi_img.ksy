meta:
  id: iwi_img
  title: Infinity Ward image (.iwi)
  file-extension: iwi
  endian: le
doc: |
  Infinity Ward `.iwi` image, version 11 (Call of Duty: Black Ops, Wii, 0x20-byte
  header) and 7 (World at War, Wii, 0x1C-byte header with four offsets,
  otherwise the same fields). Format 11 is GX CMPR / DXT1; the 0x20-byte header
  is followed by the pixel data in GX CMPR tile layout. Only files holding one
  CMPR level are decoded by nintoolbox.
seq:
  - id: magic
    contents: IWi
  - id: version
    type: u1
  - id: format
    type: u1
  - id: flags
    type: u1
  - id: width
    type: u2
  - id: height
    type: u2
  - id: depth
    type: u2
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: 5
  - id: pixels
    size-eos: true
