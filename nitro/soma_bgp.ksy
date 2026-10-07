meta:
  id: soma_bgp
  title: Monolith Soft BGP1 background graphic (Soma Bringer .bgp)
  file-extension: bgp
  endian: le
doc: |
  `BGP1` 256x192 background tile map of Soma Bringer (23 files validated)
  with a companion RGB555 palette. nintoolbox reads the header only; the
  `data_offset` / `palette_size` fields locate the two payloads.
seq:
  - id: magic
    contents: 'BGP1'
  - id: file_size
    type: u4
    doc: At least 24, at most the physical file size.
  - id: width
    type: u2
  - id: height
    type: u2
  - id: flags
    type: u4
  - id: data_offset
    type: u4
  - id: palette_size
    type: u4
  - id: rest
    size-eos: true
    doc: Palette and tile map, located by `data_offset` and `palette_size`.
