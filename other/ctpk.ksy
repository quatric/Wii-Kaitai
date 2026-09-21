meta:
  id: ctpk
  file-extension: ctpk
  endian: le
  title: Nintendo 3DS CTPK texture package
doc: |
  CTPK ("CTPK", Level5/Nintendo 3DS texture package) bundles one or more
  Pica200-format textures behind a shared header and a fixed-size entry
  table, followed by a string table (entry names) and a texture-data
  region. Modeled from `ScanCTPK()`/`GetCTPKEntry()` in nintoolbox's
  lib-ctpk.c; the bytes between the entry table and `texture_offset`
  (string table plus whatever undocumented padding) are not otherwise
  interpreted by that code, which is why `RebuildCTPKFromPrefix()` treats
  that whole span as an opaque, byte-for-byte-preserved prefix rather than
  reconstructing it field by field.

  Each entry's `data_offset` is relative to the package's `texture_offset`,
  not to the file start. Pixel data itself is Pica200-tiled (8x8
  Z-order/Morton blocks) in one of several raw or ETC1(A4)-compressed
  formats, decoded by `DecodePicaTexture()` -- not modeled here since it
  is pixel-format decoding, not container structure.
seq:
  - id: magic
    contents: "CTPK"
  - id: version
    type: u2
  - id: n_entries
    type: u2
  - id: texture_offset
    type: u4
    doc: Start of the texture-data region, relative to the file start.
  - id: texture_size
    type: u4
    doc: Total size of the texture-data region.
  - id: reserved
    size: 16
    doc: Remainder of the 0x20-byte header, unexamined by the scanner.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: n_entries
types:
  entry:
    doc: One fixed 0x20-byte record; only the first 22 bytes are read by GetCTPKEntry().
    seq:
      - id: name_offset
        type: u4
        doc: File-relative offset of this entry's NUL-terminated name, or 0 if unnamed.
      - id: data_size
        type: u4
      - id: data_offset
        type: u4
        doc: Offset of this entry's pixel data, relative to the package's texture_offset.
      - id: format
        type: u4
        doc: Pica200 pixel format (0=RGBA8888 and others handled by DecodePicaTexture()).
      - id: width
        type: u2
      - id: height
        type: u2
      - id: mip_level
        type: u1
      - id: type
        type: u1
      - id: reserved
        size: 10
        doc: Remainder of the 0x20-byte entry, unexamined by GetCTPKEntry().
    instances:
      name:
        io: _root._io
        pos: name_offset
        type: strz
        encoding: ASCII
        if: name_offset != 0
      body:
        io: _root._io
        pos: _root.texture_offset + data_offset
        size: data_size
