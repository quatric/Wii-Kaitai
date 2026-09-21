meta:
  id: scn0
  file-extension: scn0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R SCN0 scene animation
doc: |
  Scene animation: animates the scene itself (light sets, ambient
  lights, lights, fog and cameras) rather than a model, per lib-scn.h.
  It is the least common of the NW4R animation sub-files in dumped
  retail archives -- BrawlBox/BrawlCrate support it mainly for stage
  and cutscene data, where a game wants a camera fly-through or a
  scripted light change without hand-coding it, rather than for
  character models. Unlike other NW4R animations it uses a nested
  resource group: one outer group naming up to five sections
  (lightset/amblight/light/fog/camera), each holding its own group of
  fixed-size node structs -- so a lookup is a two-step walk (section
  name, then node name within that section) instead of the single flat
  group CHR0/SRT0/CLR0/VIS0 use.

  Node internals (per-slot fixed value vs. self-relative keyframe/
  colour/visibility blob, in flag-bit rather than struct-field order)
  are variable per section and not modeled here -- see lib-scn.h for
  the documented layout rules.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this SCN0 to the outer (5-section) resource group.
  - id: ofs_name
    type: s4
    doc: Offset from the start of this SCN0 to the animation's own name in the string pool.
  - id: ofs_orig_path
    type: s4
    doc: |
      Offset to the original MDL0/scene file path, as recorded by the
      exporting SDK tool.
  - id: n_frames
    type: u4
    doc: Length of the animation in frames, not counting the extra loop frame `loop` implies.
  - id: spec_light
    type: u4
    doc: |
      Specular light count, preserved verbatim from the scene the
      animation was authored against; used to size the `light` section's
      fixed-layout node structs rather than being read from them.
  - id: loop
    type: u4
    doc: Non-zero if the animation loops back to frame 0 after `n_frames`.
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
