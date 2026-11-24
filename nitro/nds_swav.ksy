meta:
  id: nds_swav
  title: Nintendo DS SDK single wave (.swav)
  file-extension: swav
  endian: le
doc: |
  Nintendo DS SDK `SWAV` single wave (after vgmstream / vgmtrans). IMA data
  starts with its own header. `loop_offset` and `len_non_loop` are in words.
seq:
  - id: magic
    contents: SWAV
  - id: bom
    size: 4
  - id: len_file
    type: u4
  - id: header_size
    type: u2
  - id: num_blocks
    type: u2
  - id: data_magic
    contents: DATA
  - id: len_data_block
    type: u4
  - id: wave_type
    type: u1
    enum: wave_type
  - id: loop_flag
    type: u1
  - id: sample_rate
    type: u2
  - id: time
    type: u2
  - id: loop_offset
    type: u2
  - id: len_non_loop
    type: u4
  - id: data
    size-eos: true
enums:
  wave_type:
    0: pcm8
    1: pcm16
    2: ima_adpcm
