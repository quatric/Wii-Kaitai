meta:
  id: chr0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R CHR0 bone animation
doc: |
  BRRES "bone animation" sub-file. CHR0 animates a model's skeleton. Each
  entry is named after a bone of a sibling MDL0 and carries up to nine
  animated scalar channels -- scale XYZ, rotation XYZ and translation XYZ.
  Every channel is independently either a single fixed float, constant for
  the whole animation, or a track of keyframes in one of several shared
  encodings (see the `nw4r_brres_anim` track formats, not modelled here).

  A 32-bit `code` word per entry selects, per channel group, whether the
  group is present at all, whether it is isotropic (one shared value for
  all three axes), which axes are fixed, and which track encoding the
  group's non-fixed tracks use -- reverse engineered from BrawlLib
  (SSBB/Types/Animations/CHR0.cs) and corrected against retail Mario Kart
  Wii data.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: u4
    doc: Offset to the resource group, relative to the start of this CHR0.
  - id: ofs_user_data
    type: u4
    if: header.version == 5
    doc: Version 5 only; not needed for a faithful re-encode.
  - id: ofs_name
    type: u4
    doc: Offset to the animation's resource name, relative to this CHR0.
  - id: ofs_orig_path
    type: u4
    doc: Offset to the original source path, relative to this CHR0, or 0.
  - id: num_frames
    type: u2
  - id: num_entries
    type: u2
  - id: loop
    type: u4
  - id: scaling_rule
    type: u4
    doc: NW4R scaling rule, preserved verbatim on re-encode.
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
    doc: |
      Standard BRRES resource group: a size/count header followed by
      count+1 fixed-size records (record #0 is a dummy root, unused here).
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
        doc: Offset to this entry's bone name, relative to this record.
      - id: ofs_data
        type: s4
        doc: Offset to the entry's chr0_entry data, relative to the resource group start.
