meta:
  id: ngcbm
  title: _NGCBM01 GameCube/Wii bitmap
  endian: be
doc: |
  `_NGCBM01` GameCube/Wii bitmap (Totally Spies! Totally Party, unpacked from
  BIGFILE `DKAP` members; see `dkap_toc`). The plain GX texel chain follows the
  0x20-byte header.
seq:
  - id: magic
    contents: '_NGCBM01'
  - id: width
    type: u2
  - id: height
    type: u2
  - id: gx_format
    type: u2
  - id: num_mips
    type: u1
  - id: flags
    type: u1
  - id: zero
    type: u4
  - id: data_offset
    type: u4
    doc: 0x20.
  - id: reserved
    size: 8
  - id: texels
    size-eos: true
