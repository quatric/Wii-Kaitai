meta:
  id: bgib
  title: BGIB level/sound pack (.gcs, .gcm)
  endian: be
doc: |
  `BGIB` level/sound pack (also embedded in `.pak`): Pheasants Forever,
  Tournament of Legends, Nickelodeon Dora/Diego/Kai-Lan/Fit, Rudolph, Pirates
  PlundArrr, The Secret Saturdays (Wii). The payload at 0x200 uses the engine's
  byte-oriented LZ: `c & 0x80` match (`word = (c << 8 | b1)` as int16, source =
  `out + (word >> 4) - 1`, length `(b1 & 15) + 2`); `c < 0x40` literal run of
  `c + 1` bytes; otherwise a byte run (next byte repeated `c - 0x3e` times).
  A raw DSP-ADPCM blob of `len_dsp_blob` bytes sits at the very end.
seq:
  - id: magic
    contents: BGIB
  - id: header_size
    type: u4
    doc: 0x1f0.
  - id: reserved0
    size: 8
  - id: pack_name
    size: 0x40
    type: strz
    encoding: ASCII
  - id: level_name
    size: 0x30
    type: strz
    encoding: ASCII
  - id: len_dsp_blob
    type: u4
    doc: 0 if none.
  - id: len_decompressed
    type: u4
  - id: reserved1
    size: 4
  - id: len_compressed
    type: u4
  - id: reserved2
    size: 0x170
    doc: Rest of the 0x1f0 header and padding up to the payload at 0x200.
  - id: payload
    size: len_compressed
