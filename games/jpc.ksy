meta:
  id: jpc
  title: JParticle effect container (.jpc)
  file-extension: jpc
  endian: be
doc: |
  JParticle effect container (`JPAC1-00` / `JPAC2-10`: Twilight Princess, Super
  Mario Galaxy, Pikmin 2, Wind Waker HD). The texture table is a run of `TEX1`
  blocks, each holding a standalone BTI image at +0x20. The particle resources
  themselves are not decoded by nintoolbox and are not modelled here.
seq:
  - id: magic
    size: 8
    type: str
    encoding: ASCII
  - id: num_resources
    type: u2
  - id: num_textures
    type: u2
  - id: resource_table_offset
    type: u4
  - id: texture_table_offset
    type: u4
  - id: reserved
    size: 0x0c
instances:
  textures:
    pos: texture_table_offset
    type: tex1
    repeat: expr
    repeat-expr: num_textures
types:
  tex1:
    seq:
      - id: magic
        contents: TEX1
      - id: len_block
        type: u4
        doc: Total block size, including this header.
      - id: unknown
        type: u4
      - id: name
        size: 0x14
        type: strz
        encoding: ASCII
      - id: bti_image
        size: len_block - 0x20
        doc: Standalone BTI image (see media/ for texture decoders).
