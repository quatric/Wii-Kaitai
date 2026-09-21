meta:
  id: vis0
  file-extension: vis0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R VIS0 bone/node visibility animation
doc: |
  Per named scene-graph node (matched by name against a sibling
  MDL0's bones/nodes), stores either a constant visible/hidden flag
  or a bit per animation frame, per lib-vis0.h. Only the fixed
  top-level header is modeled here; the resource-group entries
  (dummy root + N named 8-byte-or-larger entries) are variable-
  length and not expanded -- see lib-vis0.h for the documented
  layout.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this VIS0 to the node-entry resource group.
  - id: ofs_name
    type: s4
  - id: ofs_orig_path
    type: s4
  - id: n_frames
    type: u4
  - id: loop
    type: u4
  - id: ofs_user_data
    type: s4
    if: header.version == 4
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
