meta:
  id: njm
  title: Sega Ninja motion (.njm, "MDMN" / "MACN", big endian)
  file-extension: njm
  endian: be
doc: |
  Radirgy Noa, Illvelo. {tag, u32 size}, then {u32 mdata offset, u32 frame
  count, u16 type, u16 inp_fn}, offsets relative to file + 8. inp_fn & 15 =
  channels, taken from the set bits of `type` in ascending order. Key sizes: bit0
  position / bit2 scale / bit6 target = u32 frame + 3 floats; bit5 rotation = u16
  frame + 3 s16 BAMS angles; bit7 roll / bit8 field of view = u16 frame + s16.
seq:
  - id: tag
    size: 4
    doc: '"MDMN" (node animation) or "MACN" (camera).'
  - id: size
    type: u4
  - id: mdata_offset
    type: u4
  - id: frame_count
    type: u4
  - id: type
    type: u2
  - id: inp_fn
    type: u2
  - id: rest
    size-eos: true
