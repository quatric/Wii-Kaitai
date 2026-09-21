meta:
  id: clr0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R CLR0 material colour animation
doc: |
  BRRES "material color animation" sub-file. CLR0 animates up to 11 GX
  color targets per named material: the two light-channel material
  colors, the two light-channel ambient colors, the three TEV color
  registers and the four TEV konstant registers. Each target is either
  absent, a single constant RGBA, or one RGBA value per frame (plus a
  terminating extra frame, like CHR0/SRT0 carry).

  Layout reverse engineered from BrawlLib
  (SSBB/Types/Animations/CLR0.cs: CLR0v3/CLR0v4, CLR0Material,
  CLR0MaterialEntry, CLR0EntryFlags, EntryTarget).
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: u4
    doc: Offset to the resource group, relative to the start of this CLR0.
  - id: ofs_user_data
    type: u4
    if: header.version == 4
    doc: Version 4 only; not needed for a faithful re-encode.
  - id: ofs_name
    type: u4
  - id: ofs_orig_path
    type: u4
  - id: num_frames
    type: u2
  - id: num_entries
    type: u2
  - id: loop
    type: u4
instances:
  name:
    io: _io
    pos: ofs_name
    type: strz
    encoding: ASCII
    if: ofs_name != 0
  orig_path:
    io: _io
    pos: ofs_orig_path
    type: strz
    encoding: ASCII
    if: ofs_orig_path != 0
  group:
    io: _io
    pos: ofs_data
    type: resource_group
types:
  resource_group:
    seq:
      - id: len_group
        type: u4
      - id: count
        type: u4
      - id: record
        type: group_record
        repeat: expr
        repeat-expr: count + 1
  group_record:
    seq:
      - id: id
        type: u2
      - id: flag
        type: u2
      - id: left_index
        type: u2
      - id: right_index
        type: u2
      - id: ofs_name
        type: s4
        doc: Offset to this material's name, relative to this record.
      - id: ofs_data
        type: s4
        doc: Offset to the material record, relative to the resource group start.
  material:
    doc: One CLR0Material -- a colour-animated material.
    seq:
      - id: ofs_name
        type: u4
        doc: Offset to this material's name, relative to the start of this record.
      - id: flags
        type: u4
        doc: |
          11 target pairs: bit (2*t) is target t's "exists" flag, bit
          (2*t+1) is target t's "is constant" flag.
