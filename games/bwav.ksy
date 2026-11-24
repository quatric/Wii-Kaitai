meta:
  id: bwav
  title: Nintendo Switch BWAV
  file-extension: bwav
  endian: le
doc: Codec 0 PCM16, 1 DSP-ADPCM, 2 Switch Opus (0x80000001 stream at the start offset).
seq:
  - id: magic
    contents: BWAV
  - id: bom
    type: u2
    doc: 0xFEFF.
  - id: version
    type: u2
  - id: crc
    type: u4
  - id: prefetch
    type: u2
  - id: channel_count
    type: u2
  - id: channels
    type: channel
    repeat: expr
    repeat-expr: channel_count
types:
  channel:
    seq:
      - id: codec
        type: u2
      - id: pan
        type: u2
      - id: rate
        type: u4
      - id: total_samples
        type: u4
      - id: samples
        type: u4
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: start_offset
        type: u4
        doc: 0x34.
      - id: unk38
        size: 4
      - id: loop_end
        type: s4
        doc: -1 = none.
      - id: loop_start
        type: s4
      - id: unk44
        size: 2
      - id: history
        type: s2
        repeat: expr
        repeat-expr: 2
      - id: pad
        size: 0x4c - 0x4a
