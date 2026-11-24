meta:
  id: eaxa
  title: Electronic Arts SCHl stream (EA-XA ADPCM)
  endian: le
doc: |
  After vgmstream ea_schl / blocked_ea_schl. "SCHl", u32 header size (LE), "PT"
  + u16 platform (6 = GC/Wii) and variable patches {id, byte count, value}
  (0x80 version, 0x82 channels, 0x83 / 0xa0 codec, 0x84 rate, 0x85 samples, 0xff
  end), then blocks {id, u32 size (LE), ...}; "SCDl" blocks hold {u32 samples
  (BE), u32 channel offset * channels (BE), data}. Version 3 uses frames of 0x0f
  bytes (28 samples, byte 0xee starts an uncompressed frame).
seq:
  - id: magic
    contents: SCHl
  - id: header_size
    type: u4
  - id: pt
    contents: PT
  - id: platform
    type: u2
  - id: patches
    size: header_size - 12
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: id
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
        doc: Includes the 8-byte header.
      - id: body
        size: size - 8
