meta:
  id: rvli
  title: WordJong Party .rvli image
  file-extension: rvli
  endian: be
doc: '"rvli", "rvif" at +8, be32 1, width, height, bits per pixel (32 RGBA32, 16 RGB5A3), "eimg" at +0x24, "rvpx" at +0x38, GX-tiled pixels from 0x40.'
seq:
  - id: magic
    contents: rvli
  - id: unk4
    size: 4
  - id: rvif
    contents: rvif
  - id: one
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: bpp
    type: u4
  - id: unk20
    size: 4
  - id: eimg
    contents: eimg
  - id: unk28
    size: 0x38 - 0x28
  - id: rvpx
    contents: rvpx
  - id: unk3c
    size: 4
  - id: pixels
    size-eos: true
