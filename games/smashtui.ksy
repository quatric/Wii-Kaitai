meta:
  id: smashtui
  endian: le
  title: Super Smash Bros. 4 texture-atlas table (Texlist)
doc: |
  Super Smash Bros. 4 UI texture-atlas table ("TLST"), per
  lib-smashtui.c (ported from KillzXGaming/Smash-Forge Texlist.cs).
  The first table has one 32-bit flag word per atlas; bit 0x01000000
  marks an atlas as dynamic. The second table has one contiguous 0x20-
  byte record per texture, followed by a string table. Each name offset
  is relative to the string table, and the two copies of the offset
  must agree. UV values form a top-left/bottom-right rectangle.

  nintoolbox requires atlas_table_offset to be 0x10, the entry table
  immediately after the atlas flags, and the string table immediately
  after the texture records. Every texture name must terminate within
  the file, and its signed atlas index must be -1 (unassigned) or less
  than the atlas count. The sibling Lumen UI layout format (.lm) is a
  separate tag stream, not part of TLST.
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
  - id: atlas_flags
    type: u4
    repeat: expr
    repeat-expr: num_atlas
    doc: Per-atlas flags, not offsets; bit 0x01000000 means dynamic.
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
        doc: Byte offset of NUL-terminated name relative to string_table_offset.
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
        type: s2
        doc: Signed texture width reported by the decoder.
      - id: height
        type: s2
        doc: Signed texture height reported by the decoder.
      - id: atlas_index
        type: s2
        doc: -1 means unassigned; otherwise index into atlas_flags.
      - id: padding
        type: u2
        doc: Final two bytes of the contiguous texture record.
    instances:
      name:
        io: _root._io
        pos: _root.string_table_offset + name_offset
        type: str
        encoding: UTF-8
        terminator: 0
        doc: Texture name in the shared string table.
