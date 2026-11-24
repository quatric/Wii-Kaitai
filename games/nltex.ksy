meta:
  id: nltex
  title: Next Level Games texture bank (.rlt / .res / .dmn)
  endian: be
doc: |
  ".rlt" ("PTLG": u32 count @4, then count {u32 name hash, u32 offset, u32 size
  (top bits flags), 0} from 0x10, offsets relative to the end of the table).
  ".res"/".dmn": u32 0x20 @0, u32 count @4, count {u32 name hash, u32 offset /
  0x20, u32 size} from 0x20. Texture header (0x20): {u32 mip levels, u32 kind
  (1 RGB5A3, 2 CMPR, 3 RGBA8), 4 colour-depth bytes @8, u16 width @0xe, u16
  height @0x10} then GX-tiled levels largest first.
seq:
  - id: first
    type: u4
  - id: count
    type: u4
  - id: rest
    size-eos: true
types:
  rlt_entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: size_flags
        type: u4
      - id: zero
        type: u4
  res_entry:
    seq:
      - id: name_hash
        type: u4
      - id: offset_div_0x20
        type: u4
      - id: size
        type: u4
  texture_header:
    seq:
      - id: mip_levels
        type: u4
      - id: kind
        type: u4
      - id: depth_bytes
        size: 4
      - id: unk0c
        size: 2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: rest
        size: 0x20 - 0x12
