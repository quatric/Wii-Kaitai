meta:
  id: nintendo_ast
  title: Nintendo streamed audio (.ast)
  file-extension: ast
  endian: be
doc: |
  Nintendo GameCube/Wii/Switch streamed audio (Pikmin 2, Mario Kart: Double
  Dash!!, Super Mario Galaxy, Pac-Man Vs.). This definition is the big-endian
  `STRM` variant; a little-endian build (`MRTS` magic) has the same layout with
  all fields byte-swapped. From 0x40 on come `BLCK` blocks (`BLCK`, u32
  per-channel size, 0x18 padding) followed by every channel's data back to back.
  AFC frames are 9 bytes (scale/index byte + 16 nibbles).
seq:
  - id: magic
    contents: STRM
  - id: len_data
    type: u4
    doc: File size is this + 0x40.
  - id: codec
    type: u2
    enum: codec
  - id: bits_per_sample
    type: u2
    doc: 16.
  - id: num_channels
    type: u2
  - id: loop_flag
    type: u2
  - id: sample_rate
    type: u4
  - id: num_samples
    type: u4
  - id: loop_start
    type: u4
  - id: loop_end
    type: u4
  - id: reserved
    size: 0x20
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: magic
        contents: BLCK
      - id: len_channel
        type: u4
        doc: Bytes per channel.
      - id: padding
        size: 0x18
enums:
  codec:
    0: afc
    1: pcm16_be
