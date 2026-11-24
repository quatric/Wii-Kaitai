meta:
  id: redballmus
  title: Ultimate Red Ball Challenge .mus music
  file-extension: mus
  endian: be
doc: |
  4-byte marker (0xabababab, or 0xefefefef), 16 BE s16 DSP-ADPCM coefficients,
  {u32 id, u32 0, u32 size}, then mono DSP-ADPCM frames: 2 * size bytes for
  0xabababab files and size bytes for 0xefefefef ones. Rate not stored (32 kHz).
seq:
  - id: marker
    type: u4
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: id
    type: u4
  - id: zero
    type: u4
  - id: size
    type: u4
  - id: frames
    size-eos: true
