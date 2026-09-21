meta:
  id: bglpbd
  file-extension: bglpbd
  imports:
    - /other/aamp
  title: Nintendo BGLPBD light-probe data
doc: |
  Light-probe grid data (min/max/step bounds, per-probe indices, and
  27-float spherical-harmonic buffers per probe) for Nintendo EAD/EPD
  Switch titles. On disk this is nothing but a regular AAMP parameter
  archive (see `aamp.ksy`) whose root parameter I/O type name is the
  literal string "glpbd" -- V1/big-endian is written with
  `is_switch == false`, V2/little-endian with `is_switch == true|1`.
  There is no separate BGLPBD binary layout to model: every field this
  tool reads (bounding box, probe index grid, SH coefficient buffers,
  ambient/indirect-light settings) is just a named AAMP parameter inside
  that tree, decoded via the ordinary AAMP object/entry walk.
seq:
  - id: aamp
    type: aamp
