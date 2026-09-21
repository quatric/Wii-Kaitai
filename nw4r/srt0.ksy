meta:
  id: srt0
  file-extension: srt0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R SRT0 texture SRT animation
doc: |
  Animates the texture matrix of a material (scale X/Y, rotation,
  translation X/Y per texture layer), per lib-srt.h. Each entry is
  named after a material of a sibling MDL0 and holds a bitmask of
  which of the 8 ordinary + 3 indirect texture layers are animated.
  Unlike CHR0, every animated channel always uses the I12 (raw
  float keyframe) encoding, so there is no format-selector field.
  Only the fixed top-level header is modeled here; entry/texture/
  channel internals are variable-length and not expanded -- see
  lib-srt.h for the documented layout.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this SRT0 to the material-entry resource group.
  - id: ofs_name
    type: s4
  - id: ofs_orig_path
    type: s4
  - id: n_frames
    type: u2
  - id: n_entries
    type: u2
  - id: loop
    type: u4
  - id: matrix_mode
    type: u4
instances:
  name:
    pos: ofs_name - 4
    type: pooled_string
    if: ofs_name != 0
types:
  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: UTF-8
