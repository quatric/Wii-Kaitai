meta:
  id: iswsdsp
  title: Codemasters iSWS DSP stream (.was)
  file-extension: was
  endian: be
doc: |
  Codemasters `iSWS` streams (Dirt 2, Wii `Audio/wav/**/*.was`). One standard
  0x60-byte DSP-ADPCM header per channel from 0x20; the ADPCM data at
  `0x20 + 0x60 * channels`.
seq:
  - id: magic
    contents: iSWS
  - id: header_size
    type: u4
    doc: 0x18.
  - id: num_channels
    type: u4
    doc: 1 or 2.
  - id: reserved
    size: 0x14
  - id: dsp_headers
    size: 0x60
    repeat: expr
    repeat-expr: num_channels
  - id: adpcm
    size-eos: true
