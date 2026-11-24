meta:
  id: capcomtex
  title: Capcom MT Framework Wii .tex / .plt wrapper
  endian: be
doc: |
  Sengoku Basara 3. 0x20-byte header ({magic "\0XET" / "\0TLP", u32 version,
  u32 0x20, ...}) in front of a plain BRRES holding TEX0 / PLT0 data.
seq:
  - id: magic
    size: 4
  - id: version
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: rest_of_header
    size: header_size - 12
  - id: brres
    size-eos: true
