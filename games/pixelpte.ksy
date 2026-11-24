meta:
  id: pixelpte
  title: Pixel Ent. texture export (.pte / .pfi)
  endian: be
doc: Big-endian header {u32 13, u32 type, name, source path ... .tga} followed by a plain Wii TPL (0x0020AF30) to EOF.
seq:
  - id: thirteen
    type: u4
  - id: type
    type: u4
  - id: rest
    size-eos: true
