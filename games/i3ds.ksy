meta:
  id: i3ds
  title: Codemasters 3DS i3DS interleaved DSP (.3ds)
  file-extension: 3ds
  endian: le
doc: |
  F1 2011. Data size @8, interleave @0xc (0 = mono), then one or two CWAV
  headers (0xc0 each) from 0x10 (rate @+0x4c, samples @+0x54, LE DSP
  coefficients @+0x7c), "DATA" and ADPCM interleaved from 0x10 + 0xc0 * channels
  + 0x10.
seq:
  - id: magic
    size: 4
  - id: unk4
    size: 4
  - id: data_size
    type: u4
  - id: interleave
    type: u4
  - id: rest
    size-eos: true
