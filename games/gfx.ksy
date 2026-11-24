meta:
  id: gfx
  title: Scaleform GFx movie (.gfx)
  file-extension: gfx
  endian: le
doc: '"CFX" + u8 version + u32 uncompressed length + zlib stream (the Flash CWS layout).'
seq:
  - id: magic
    contents: CFX
  - id: version
    type: u1
  - id: uncompressed_length
    type: u4
  - id: body
    size-eos: true
    process: zlib
