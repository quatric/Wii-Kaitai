meta:
  id: shp0
  file-extension: shp0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R SHP0 vertex morph animation
doc: |
  Blends between named vertex sets of a polygon over time, per
  lib-shp.h. Each entry names one polygon (material) and carries one
  keyframe track per morph target, the targets themselves named by
  index into a file-level string list. Only the fixed top-level
  header is modeled here; entry/track internals (fixed-vs-keyed
  tracks, `(frame, value, tangent)` keys) are variable-length and
  not expanded -- see lib-shp.h for the documented layout.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this SHP0 to the polygon-entry resource group.
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
