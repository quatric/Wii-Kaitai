meta:
  id: xtx
  endian: le
  title: Nintendo Switch XTX texture container
doc: |
  Nintendo Switch XTX texture container ("DFvN"), per lib-xtx.h
  (verified against KillzXGaming/Switch-Toolbox XTX.cs). "HBvN"
  blocks follow the header; block type 2 is a fixed 120-byte texture
  header, block type 3 is that texture's Tegra block-linear pixel
  payload, paired in order. Only the block envelope is modeled here.
seq:
  - id: magic
    contents: "DFvN"
  - id: header_size
    type: u4
  - id: version_major
    type: u4
  - id: version_minor
    type: u4
  - id: blocks
    type: block_t
    repeat: eos
types:
  block_t:
    seq:
      - id: magic
        contents: "HBvN"
      - id: block_size
        type: u4
      - id: data_size
        type: u8
      - id: data_offset
        type: s8
        doc: Relative to the start of this block.
      - id: block_type
        type: u4
      - id: index
        type: u4
      - id: body
        size: block_size - 32
