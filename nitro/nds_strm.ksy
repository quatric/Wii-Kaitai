meta:
  id: nds_strm
  title: Nintendo DS SDK stream (.strm)
  file-extension: strm
  endian: le
doc: |
  Nintendo DS SDK `STRM` stream (layout after vgmstream `nds_strm.c` / vgmtrans
  `NDSInstrSet`). Channels are interleaved per block and every IMA block starts
  with a `{s16 predictor, u16 step index}` header.
seq:
  - id: magic
    contents: STRM
  - id: bom
    contents: [0xff, 0xfe, 0x00, 0x01]
  - id: len_file
    type: u4
  - id: header_size
    type: u2
  - id: num_blocks
    type: u2
  - id: head_magic
    contents: HEAD
  - id: len_head
    type: u4
  - id: codec
    type: u1
    enum: codec
  - id: loop_flag
    type: u1
  - id: num_channels
    type: u1
  - id: pad0
    size: 1
  - id: sample_rate
    type: u2
  - id: pad1
    size: 2
  - id: loop_start
    type: u4
  - id: num_samples
    type: u4
  - id: data_offset
    type: u4
  - id: num_data_blocks
    type: u4
  - id: block_size
    type: u4
  - id: samples_per_block
    type: u4
  - id: last_block_size
    type: u4
enums:
  codec:
    0: pcm8
    1: pcm16
    2: ima_adpcm
