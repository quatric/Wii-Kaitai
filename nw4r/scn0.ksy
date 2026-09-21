meta:
  id: scn0
  file-extension: scn0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R SCN0 scene animation
doc: |
  Animates the scene itself (light sets, ambient lights, lights, fog
  and cameras) rather than a model, per lib-scn.h. Unlike other NW4R
  animations it uses a nested resource group: one outer group naming
  up to five sections (lightset/amblight/light/fog/camera), each
  holding its own group of fixed-size node structs. Node internals
  (per-slot fixed value vs. self-relative keyframe/colour/visibility
  blob, in flag-bit rather than struct-field order) are variable per
  section and not modeled here -- see lib-scn.h for the documented
  layout rules.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this SCN0 to the outer (5-section) resource group.
  - id: ofs_name
    type: s4
  - id: ofs_orig_path
    type: s4
  - id: n_frames
    type: u4
  - id: spec_light
    type: u4
    doc: Specular light count, preserved verbatim.
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
