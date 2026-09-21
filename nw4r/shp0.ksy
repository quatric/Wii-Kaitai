meta:
  id: shp0
  file-extension: shp0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R SHP0 vertex morph animation
doc: |
  Vertex-morph ("shape") animation: blends between named vertex sets of a
  polygon over time, per lib-shp.h. BrawlBox/BrawlCrate call this `SHP0`
  and model it as one entry per *object* (not material -- shape animation
  targets an MDL0 object's replacement vertex arrays, unlike SRT0/CLR0
  which target materials by name), carrying one keyframe track per morph
  target. Wexos's Toolbox and Tockdom's MDL0 documentation both note SHP0
  is the rarest of the NW4R animation formats in retail Wii titles --
  most games instead drive visual variation through CLR0/SRT0/VIS0, and
  SHP0 shows up mainly where a model needs true per-vertex deformation
  (e.g. squash-and-stretch or facial blend shapes) that a bone or texture
  animation cannot express.

  Each morph target is named by index into a file-level string list
  rather than carrying its own name inline, so a target's identity comes
  from position, not from a pooled-string offset next to its track --
  matching how the sibling MDL0 stores its vertex-set names.

  Only the fixed top-level header is modeled here; entry/track internals
  (fixed-vs-keyed tracks, `(frame, value, tangent)` keys, and the
  target-index list) are variable-length and not expanded -- see
  lib-shp.h for the documented layout.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this SHP0 to the polygon-entry resource group.
  - id: ofs_name
    type: s4
    doc: Offset from the start of this SHP0 to the animation's own name in the string pool.
  - id: ofs_orig_path
    type: s4
    doc: |
      Offset to the original MDL0 file path, as recorded by the exporting
      SDK tool; present so an editor can re-link the animation to the
      model it was authored against.
  - id: n_frames
    type: u2
    doc: Length of the animation in frames, not counting the extra loop frame `loop` implies.
  - id: n_entries
    type: u2
    doc: Number of animated polygon (object) entries in the resource group below.
  - id: loop
    type: u4
    doc: Non-zero if the animation loops; when set, playback wraps past `n_frames` back to frame 0.
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
