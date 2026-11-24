meta:
  id: pikmin_mod
  title: Pikmin 1 .mod model
  file-extension: mod
  endian: be
doc: |
  Chain of {u32 type, u32 length} chunks (big endian), each starting on a 0x20
  boundary, ending with type 0xFFFF. After the projectPiki decompilation (CC0).
  Geometry plus base textures; joints are baked into the vertices.
seq:
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.type == 0xffff
types:
  chunk:
    seq:
      - id: type
        type: u4
      - id: length
        type: u4
      - id: body
        size: length
      - id: align
        size: (-(length + 8)) % 0x20
