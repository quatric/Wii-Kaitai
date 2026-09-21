meta:
  id: sfx
  endian: le
  title: Monster Games SFX audio (Excite Truck / ExciteBots, Wii)
doc: |
  Monster Games ".sfx" DSP-ADPCM audio, per lib-sfx.c/.h. A fixed
  0x80-byte header (mixed little/big-endian fields, kept as they
  appear on disc) over a plain Nintendo DSP-ADPCM stream.
seq:
  - id: data_size
    type: u4
    doc: Payload bytes after the header; + 0x80 equals the file size exactly.
  - id: header_size
    type: u4
    doc: Always 0x80.
  - id: unknown_08
    size: 0x10 - 8
  - id: sample_rate
    type: u4
  - id: byte_rate
    type: u4
    doc: sample_rate * 2 (decoded audio is 16-bit mono).
  - id: unknown_18
    size: 0x34 - 0x18
  - id: num_nibbles
    type: u4be
  - id: unknown_38
    size: 0x3c - 0x38
  - id: coef
    type: s2be
    repeat: expr
    repeat-expr: 16
  - id: frames
    size-eos: true
    doc: DSP-ADPCM frames, one predictor/scale byte then 14 nibbles each.
