meta:
  id: glacier_whd
  title: IO Interactive Glacier sound bank header (.WHD)
  file-extension: whd
  endian: be
doc: |
  Mini Ninjas (Wii). Both .WHD and .WAV start {u32, u32 file size, 0x03000000,
  0x04000000}. 0x24-byte records follow. A DSP record is preceded by
  align8(46 * channels) + 8 bytes holding one 46-byte block per channel (32
  coefficient bytes, u16 gain, u16 predictor/scale, u16 hist1, u16 hist2, 6 pad).
seq:
  - id: unk0
    type: u4
  - id: file_size
    type: u4
  - id: marker_a
    type: u4
    doc: 0x03000000.
  - id: marker_b
    type: u4
    doc: 0x04000000.
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: type
        type: u2
        doc: 1 PCM, 0x76 DSP-ADPCM.
      - id: flags
        type: u2
        doc: Bit 15 streamed from Wii_*.str banks.
      - id: rate
        type: u4
      - id: format
        type: u4
        doc: 0x10 16-bit PCM, 4 DSP-ADPCM.
      - id: decoded_bytes
        type: u4
      - id: data_size
        type: u4
      - id: channels
        type: u4
      - id: data_offset
        type: u4
      - id: samples
        type: u4
      - id: tail
        size: 0x24 - 0x24
