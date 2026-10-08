meta:
  id: namco_nub
  title: Namco NUB sound bank (Family Ski & Snowboard, Family Jockey)
  file-extension: nub
  endian: be
doc: |
  Namco "NUB" sound bank (Family Ski & Snowboard, Family Jockey, ...). A
  table of offsets leads to 0x160-byte stream header blocks, each starting
  with a Namco `IDSP` header; the standard 0x60-byte GameCube DSP header of
  channel 0 sits at +0x40 of the block, and the block's +0xbc word is the END
  offset of the stream inside the data region. nintoolbox writes mono streams
  out as standalone `.dsp`.

  `table[i] + 0xbc` is the absolute address of block *i*.
seq:
  - id: version
    type: u4
    doc: 0x00020100.
  - id: zero_04
    type: u4
  - id: unknown_08
    type: u4
  - id: count
    type: u4
  - id: header_region_size
    type: u4
    doc: The data region starts here.
  - id: data_region_size
    type: u4
  - id: table_offset
    type: u4
    doc: Always 0x20 (the table itself starts at 0x1c).
  - id: table
    type: u4
    repeat: expr
    repeat-expr: count
instances:
  data_region:
    pos: header_region_size
    size: data_region_size
types:
  stream_block:
    doc: Apply at `table[i] + 0xbc`.
    seq:
      - id: magic
        contents: 'IDSP'
      - id: unknown_04
        type: u4
      - id: channels
        type: u4
      - id: sample_rate
        type: u4
      - id: num_samples
        type: u4
      - id: unknown_14
        size: 0x2c - 0x14
      - id: stream_size
        type: u4
      - id: unknown_30
        size: 0x40 - 0x30
      - id: dsp_header
        size: 0x60
        doc: Standard GameCube DSP header of channel 0.
      - id: rest
        size: 0xbc - 0xa0
      - id: end_offset
        type: u4
        doc: END offset of the stream in the data region.
