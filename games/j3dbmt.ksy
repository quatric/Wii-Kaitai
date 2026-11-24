meta:
  id: j3dbmt
  title: J3D material table (BMT, "J3D2bmt3")
  file-extension: bmt
  endian: be
doc: |
  Same 32-byte head and TLV chunk framing as `j3d` (8 magic "J3D2bmt3", u32 file
  size, u32 section count, 16 opaque bytes), but holding only material and
  texture chunks (MAT3, TEX1). The TEX1 section holds the material textures.
seq:
  - id: magic
    contents: ["J3D2bmt", 0x33]
  - id: file_size
    type: u4
  - id: section_count
    type: u4
  - id: dummy
    size: 16
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: section_count
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
        doc: Includes the 8-byte tag + size header.
      - id: body
        size: size - 8
