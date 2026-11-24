meta:
  id: wtpak
  title: Our House Party .wtpak
  file-extension: wtpak
  endian: be
seq:
  - id: crc
    type: u4
  - id: one
    type: u4
  - id: count
    type: u4
  - id: unk
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: size
        type: u4
      - id: offset
        type: u4
      - id: name_hash
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
