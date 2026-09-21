meta:
  id: camtexbank
  endian: be
  title: Camelot GX texture bank
doc: |
  Camelot Software Planning's own texture container, seen in Mario Golf:
  Toadstool Tour and Mario Power Tennis (GameCube). Camelot's GameCube
  discs name every asset with single letters (files/A/U/R/...) so there
  is no extension to key on, and the container is usually wrapped in
  Camelot's own LZ codec (see camelot.ksy) and/or embedded inline inside
  a PPC relocatable module (a model file carrying its own textures), so a
  bank can start at any 4-byte-aligned offset rather than at the start of
  a file.

  Layout, big-endian, after any outer LZ decompression:
    0x00  u32 magic 0x0020af30
    0x04  u32 texture count
    0x08  u32 offset of the entry-pointer table (relative to the bank)
          table: `count` * { u32 entry offset (relative to the bank), u32 pad }
    entry (16 bytes):
      0x00  u16 width, u16 height
      0x04  u32 GX texture format (the GX hardware's own numbering, not
            the same numbering BRRES/TEX0 uses)
      0x08  u32 offset of the pixel data, relative to the bank
      0x0c  u32 sampler state (wrap modes / filtering, not decoded here)

  All offsets inside a bank -- the entry table, each entry, and each
  entry's pixel data -- are relative to the bank's own start, not to the
  file, which is exactly what lets one bank sit at an arbitrary offset
  inside a larger PPC module. Pixel data for each level is stored in the
  GX hardware's native tiled block layout (block size depends on
  `format`); palette-indexed formats (C4/C8/C14X2) are not supported by
  the reference tool since where their palette lives in these files is
  unknown.
seq:
  - id: magic
    contents: [0x00, 0x20, 0xaf, 0x30]
  - id: num_textures
    type: u4
  - id: ofs_entry_table
    type: u4
    doc: Offset of the entry-pointer table, relative to the start of this bank.
instances:
  entry_table:
    io: _io
    pos: ofs_entry_table
    type: entry_pointer
    repeat: expr
    repeat-expr: num_textures
types:
  entry_pointer:
    seq:
      - id: ofs_entry
        type: u4
        doc: Offset of this texture's entry, relative to the start of the bank.
      - id: pad
        type: u4
    instances:
      entry:
        io: _root._io
        pos: ofs_entry
        type: texture_entry
  texture_entry:
    seq:
      - id: width
        type: u2
      - id: height
        type: u2
      - id: format
        type: u4
        enum: gx_texture_format
      - id: ofs_data
        type: u4
        doc: Offset of the raw GX pixel data, relative to the start of the bank.
      - id: sampler_state
        type: u4
        doc: Wrap/filter sampler state; not decoded here.
enums:
  gx_texture_format:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: rgb565
    5: rgb5a3
    6: rgba32
    8: c4
    9: c8
    10: c14x2
    14: cmpr
