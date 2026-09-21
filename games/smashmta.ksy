meta:
  id: smashmta
  endian: be
  title: Super Smash Bros. 4 material animation (MTA4)
doc: |
  Super Smash Bros. 4 material animation (.mta), per
  lib-smashmta.c (ported from KillzXGaming/Smash-Forge MTA.cs).
  Models the fixed 44-byte header and the material/visibility
  offset tables; the material/pattern/property/visibility record
  internals pointed to by those offsets are documented in the
  source as a web of relative offsets and are not expanded here.
seq:
  - id: magic
    contents: "MTA4"
  - id: unknown_04
    size: 20
  - id: mat_count
    type: u4
  - id: mat_table_offset
    type: u4
  - id: vis_count
    type: u4
  - id: vis_table_offset
    type: u4
instances:
  material_offsets:
    type: u4
    repeat: expr
    repeat-expr: mat_count
    pos: mat_table_offset
  visibility_offsets:
    type: u4
    repeat: expr
    repeat-expr: vis_count
    pos: vis_table_offset
