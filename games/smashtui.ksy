meta:
  id: smashtui
  endian: le
  title: Super Smash Bros. 4 texture-atlas table (Texlist)
doc: |
  Super Smash Bros. 4 UI texture-atlas table ("TLST"), per
  lib-smashtui.c (ported from KillzXGaming/Smash-Forge Texlist.cs).
  The sibling Lumen UI layout format (.lm, magic-detected via a
  second header word) is a variable-length bytecode/tag stream (SWF-
  derived DoAction/PlaceObject/... tags) and is not modeled here.
seq:
  - id: magic
    contents: "TLST"
  - id: unknown_04
    size: 2
  - id: num_atlas
    type: u2
  - id: num_textures
    type: u2
  - id: atlas_table_offset
    type: u2
    doc: Always 0x10.
  - id: entry_table_offset
    type: u2
  - id: string_table_offset
    type: u2
  - id: atlas_offsets
    type: u4
    repeat: expr
    repeat-expr: num_atlas
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_textures
types:
  entry_t:
    doc: 0x20-byte contiguous entry (name offset x2, 4 UV floats, w/h/atlas shorts, pad).
    seq:
      - id: name_offset
        type: u4
      - id: name_offset2
        type: u4
        doc: Duplicate of name_offset in every known file.
      - id: u0
        type: f4
      - id: v0
        type: f4
      - id: u1
        type: f4
      - id: v1
        type: f4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: atlas_index
        type: u2
        doc: 0xffff means unassigned.
      - id: padding
        type: u2
