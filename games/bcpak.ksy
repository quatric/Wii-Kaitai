meta:
  id: bcpak
  title: .bcpak resource pack
  file-extension: bcpak
  endian: be
doc: |
  `.bcpak` resource pack (Top Shot Arcade, Our House - Party!
  `paks/*.bcpak`). The first entry's offset ends the table. TPL members are
  recognisable by their magic; everything else is opaque.
seq:
  - id: magic
    contents: [0x9a, 0x3f]
  - id: num_entries
    type: u2
  - id: pack_hash
    type: u4
  - id: constant
    contents: [0xbc, 0xb0, 0xb5, 0x30]
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: len_data
        type: u4
      - id: offset
        type: u4
      - id: resource_hash
        type: u4
      - id: check
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
