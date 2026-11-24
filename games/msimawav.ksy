meta:
  id: msimawav
  title: Microsoft IMA ADPCM WAV (format tag 0x11)
  file-extension: wav
  endian: le
doc: |
  Per block and channel a 4-byte header {s16 predictor, u8 step index, u8 0} (the
  predictor is the first sample), followed by 4-byte groups of 8 nibbles per
  channel, channels interleaved; the sample count comes from "fact".
seq:
  - id: magic
    contents: RIFF
  - id: size
    type: u4
  - id: wave
    contents: WAVE
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size
      - id: pad
        size: size % 2
  fmt:
    seq:
      - id: format_tag
        type: u2
        doc: 0x11.
      - id: channels
        type: u2
      - id: sample_rate
        type: u4
      - id: byte_rate
        type: u4
      - id: block_align
        type: u2
      - id: bits_per_sample
        type: u2
      - id: extra_size
        type: u2
      - id: samples_per_block
        type: u2
