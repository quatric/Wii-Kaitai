meta:
  id: thq_pack
  title: THQ Studio Australia "pack" archive (Nickelodeon Avatar)
  file-extension: pak
  endian: be
doc: |
  "pack" data archive of THQ Studio Australia's Nickelodeon Avatar games on
  Wii (`c2_DATA.PAK`, `mn_DATA.PAK`, ...); verified on nine retail files.
  Names are NUL-terminated `data/...` paths; payloads sit on 0x800
  boundaries and are stored as is (usually inner `.pak` / `.rad` files).
seq:
  - id: magic
    contents: 'pack'
  - id: version
    type: u4
    doc: Always 1.
  - id: names_size
    type: u4
  - id: total_size
    type: u4
    doc: The file size rounded up to 0x800.
  - id: names_offset
    type: u4
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name_offset
        type: u4
        doc: Offset into the name table (which begins at `names_offset`).
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: zero
        type: u4
    instances:
      name:
        pos: _root.names_offset + name_offset
        type: strz
        encoding: ASCII
        io: _root._io
      body:
        pos: offset
        size: size
        io: _root._io
