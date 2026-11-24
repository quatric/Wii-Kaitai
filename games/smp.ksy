meta:
  id: smp
  title: Terminal Reality Infernal Engine .smp (small header)
  file-extension: smp
  endian: le
doc: Guilty Party (Wii). Codec 2 = DSP-ADPCM.
seq:
  - id: version
    type: u4
    doc: 8.
  - id: guid
    size: 16
  - id: zero
    type: u4
  - id: samples
    type: u4
  - id: data_offset
    type: u4
    doc: 0x80.
  - id: data_size
    type: u4
  - id: codec
    type: u4
  - id: channels
    type: u1
  - id: bits
    type: u1
  - id: rate
    type: u2
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
instances:
  data:
    pos: data_offset
    size: data_size
