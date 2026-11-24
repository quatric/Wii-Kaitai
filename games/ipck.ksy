meta:
  id: ipck
  title: iPck index pack (.bin)
  file-extension: bin
  endian: be
doc: |
  `iPck` offset-table pack (Tales of Symphonia: Dawn of the New World
  `LVDPack.bin`, Wii). A table of u32 offsets, relative to `data_offset`,
  follows the header; 0xFFFFFFFF marks an absent entry and the present ones
  ascend. Entry i spans from its offset to the next present offset, and the
  last present entry runs to the end of the file.
seq:
  - id: magic
    contents: iPck
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: 0x10.
  - id: data_offset
    type: u4
instances:
  offsets:
    pos: table_offset
    type: u4
    repeat: expr
    repeat-expr: count
    doc: 0xFFFFFFFF = absent entry.
  data:
    pos: data_offset
    size-eos: true
