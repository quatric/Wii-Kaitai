meta:
  id: ktm
  title: Cursed Mountain asset bundle (.dat)
  file-extension: dat
  endian: be
doc: |
  Cursed Mountain (Wii) `.dat` asset bundle. The blob (NUL-separated,
  backslash-separated paths such as `wii\hud\textures\`) starts at 0x40, the entry
  table right behind it and the member data behind the table. Members are zlib
  streams when the flag is set. Bundles are up to 100 MB, so no data instance is
  declared.
seq:
  - id: magic
    contents: [0xd2, 0xf1, 0x7e, 0x00]
  - id: name
    size: 0x1c
    type: strz
    encoding: ASCII
  - id: zero
    type: u4
  - id: num_entries
    type: u4
  - id: one
    type: u4
  - id: len_entry_table
    type: u4
    doc: Entry count * entry size, padded to 0x20.
  - id: entry_size
    type: u4
    doc: 0x30 or 0x3c.
  - id: len_directory_blob
    type: u4
  - id: reserved
    size: 8
  - id: directory_blob
    size: len_directory_blob
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: hash
        type: u4
      - id: directory_offset
        type: u4
        doc: Into the directory blob.
      - id: data_offset
        type: u4
      - id: len_stored
        type: u4
      - id: len_unpacked
        type: u4
      - id: zlib_flag
        type: u4
      - id: name
        size: _root.entry_size - 24
        type: strz
        encoding: ASCII
