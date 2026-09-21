meta:
  id: vis0
  file-extension: vis0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R VIS0 bone/node visibility animation
doc: |
  Visibility animation: per named scene-graph node (matched by name
  against a sibling MDL0's bones or objects), stores either a constant
  visible/hidden flag or a bit per animation frame, per lib-vis0.h.
  BrawlBox/BrawlCrate call this `VIS0`; on Tockdom it is documented as
  the format behind effects like blinking eyes, toggled damage decals,
  and multi-costume models that swap visible parts in and out rather
  than changing geometry. Because each stored value is a single bit, a
  VIS0 entry's per-frame data is far more compact than CHR0/SRT0/CLR0
  tracks -- it is a bitstream, not a float array.

  Only the fixed top-level header is modeled here; the resource-group
  entries (dummy root + N named entries, each an 8-byte or larger header
  followed by the per-frame bit data when not constant) are variable-
  length and not expanded -- see lib-vis0.h for the documented layout.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this VIS0 to the node-entry resource group.
  - id: ofs_name
    type: s4
    doc: Offset from the start of this VIS0 to the animation's own name in the string pool.
  - id: ofs_orig_path
    type: s4
    doc: |
      Offset to the original MDL0 file path, as recorded by the exporting
      SDK tool.
  - id: n_frames
    type: u4
    doc: Length of the animation in frames, not counting the extra loop frame `loop` implies.
  - id: loop
    type: u4
    doc: Non-zero if the animation loops back to frame 0 after `n_frames`.
  - id: ofs_user_data
    type: s4
    if: header.version == 4
    doc: |
      Offset to a trailing user-data resource group, only present from
      version 4 onward -- matching the same version gate CLR0 and CHR0
      use for their own `ofs_user_data` fields.
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
