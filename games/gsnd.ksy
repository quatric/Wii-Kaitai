meta:
  id: gsnd
  title: Tecmo GSND sound header (.gsp)
  file-extension: gsp
  endian: be
doc: |
  Super Swing Golf 1/2 (Wii). Chunk list from the offset @0x10, each {id, full
  size, ...}: "DATA" {data size, codec (4 = DSP-ADPCM), rate @8, channels u16
  @0xe, samples @0x14}, "GCEX" {size, block header size @4, block count @8,
  DSP coefficients @0x18, 0x30 per channel}. The companion .gsb holds blocks of
  {0x20-byte header, 0x8000 bytes per channel}.
seq:
  - id: unk
    size: 0x10
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: id
        size: 4
        type: str
        encoding: ASCII
      - id: full_size
        type: u4
      - id: body
        size: full_size - 8
