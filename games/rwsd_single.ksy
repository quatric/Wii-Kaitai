meta:
  id: rwsd_single
  title: Single-stream NW4R wave sound data (.rwsd / .brwsd)
  file-extension: rwsd
  endian: be
doc: |
  Header "RWSD" 0xFEFF0102. The WAVE block (offset @0x18) holds one wave {codec
  @0x10 (0 PCM8, 1 PCM16 BE, 2 DSP-ADPCM), loop @0x11, channels @0x12, rate u16
  @0x14, loop start nibble @0x18, nibble count @0x1c, stream size per channel
  @0x50, DSP coefficients @0x6c with 0x30 per channel}; audio follows at the data
  offset @8 (after an optional "LABL" block).
seq:
  - id: magic
    contents: RWSD
  - id: bom
    type: u2
  - id: version
    type: u2
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: block_count
    type: u2
  - id: data_offset
    type: u4
  - id: data_size
    type: u4
  - id: wave_offset
    type: u4
  - id: rest
    size-eos: true
