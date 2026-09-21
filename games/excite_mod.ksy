meta:
  id: excite_mod
  file-extension: mod
  endian: le
  title: Monster Games NDL2/NDL3 model (Excite Truck / ExciteBots, Wii)
doc: |
  Header of the Monster Games "3LDN"/"2LDN" (`NDL3`/`NDL2` read as a
  little-endian magic) `.mod` model container, ported from nintoolbox's
  `lib-excite.c` (`DecodeExciteMOD`). Excite Truck uses the older "2LDN"
  revision, ExciteBots the "3LDN" revision; both share this header shape.

  The magic need not sit at file offset 0 -- most real files carry a
  small texture-filename table before it, so `magic` should be searched
  for rather than assumed at the start of the file. This definition
  covers only the fixed 0x40-byte header; the geometry that follows is a
  genuine embedded GameCube GX display list whose vertex format is
  self-describing via GX vertex-attribute-table (VAT) register writes
  inside the display list itself, so it is not representable as a static
  Kaitai struct and is not modeled here -- see the long comment above
  `DecodeExciteMOD()` in `lib-excite.c` for the full recovered algorithm.
seq:
  - id: magic
    size: 4
    doc: '"3LDN" (ExciteBots) or "2LDN" (Excite Truck).'
  - id: dl_end
    type: u4
    doc: |
      End offset (from the magic) of the display-list region. NDL2
      stores this as a u16 with the high half filled with the 0xe3e3
      filler byte pair rather than a real u32.
  - id: version
    type: u4
    doc: Constant 0x0e1e in both games; not relied upon by the reader.
  - id: format_flags
    type: u4
    doc: Constant 0x82 in most samples; other real values exist too.
  - id: unknown_10
    size: 8
  - id: bounding_radius
    type: f4
  - id: vertex_position_count
    type: u4
  - id: unknown_20
    size: 16
    doc: More unmapped fields, not used by the decoder.
