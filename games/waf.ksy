meta:
  id: waf
  title: Major Minor's Majestic March .waf stream
  file-extension: waf
  endian: be
doc: |
  Chain of chunks, each starting at the next multiple of 0x20 after the
  previous chunk's end (offset + 0x10 + size). Every chunk holds a complete
  0x60-byte DSP-ADPCM header plus data.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: one
        type: u2
      - id: two
        type: u2
      - id: size
        type: u4
      - id: samples
        type: u4
      - id: rate
        type: u4
      - id: dsp
        size: size
      - id: align
        size: (-(size + 0x10)) % 0x20
