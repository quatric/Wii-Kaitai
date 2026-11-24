meta:
  id: mcpk
  title: Switch 2 Zelda mesh codec package (.mc / .bfres.mc)
  file-extension: mc
  endian: le
doc: |
  Only the container layout is decoded. Section A starts with "FMSH" {u32
  version 0x10000, workMemSize, two output sizes, u32 0x129, entropy coded data}.
  28 + A + B == file size. Payloads are not zstd frames and not the 0.x layout
  of the public MeshCodec decoder.
seq:
  - id: magic
    contents: MCPK
  - id: micro
    type: u1
  - id: minor
    type: u1
  - id: major
    type: u2
  - id: flags
    type: u4
  - id: size_a
    type: u4
  - id: x
    type: u4
  - id: size_b
    type: u4
  - id: marker
    type: u4
    doc: 0x803.
  - id: section_a
    size: size_a
  - id: section_b
    size: size_b
