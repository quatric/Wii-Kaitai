meta:
  id: gcub
  title: Black Box / Shaba GCub audio (.gcub)
  file-extension: gcub
  endian: be
doc: Sega Soccer Slam, Shrek Superslam. ADPCM from 0x60 (0x88 after a "GCxx" tag at 0x60); stereo block (0x8000) or byte interleaved.
seq:
  - id: magic
    contents: GCub
  - id: channels
    type: u4
  - id: rate
    type: u4
  - id: data_size
    type: u4
  - id: dsp_info
    size: 0x20
    repeat: expr
    repeat-expr: channels
  - id: data
    size-eos: true
