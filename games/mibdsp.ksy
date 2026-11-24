meta:
  id: mibdsp
  title: Disney Think Fast .MIB music
  file-extension: mib
  endian: be
doc: Nintendo DSP-ADPCM channel files stored back to back; every channel has its own 0x60-byte DSP header at a 0x800-aligned offset (0 and 0x220000 in BT.MIB).
seq:
  - id: sample_count
    type: u4
  - id: nibble_count
    type: u4
  - id: rate
    type: u4
  - id: loop_flag
    type: u2
  - id: format
    type: u2
  - id: loop_start
    type: u4
  - id: loop_end
    type: u4
  - id: current
    type: u4
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
  - id: gain
    type: u2
  - id: initial_ps
    type: u2
  - id: hist
    type: s2
    repeat: expr
    repeat-expr: 2
  - id: loop_ps
    type: u2
  - id: loop_hist
    type: s2
    repeat: expr
    repeat-expr: 2
  - id: pad
    size: 22
  - id: data
    size-eos: true
