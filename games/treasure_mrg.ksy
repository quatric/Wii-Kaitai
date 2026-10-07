meta:
  id: treasure_mrg
  title: Treasure DS Multi-Resource Archive (.mrg)
  file-extension: mrg
  endian: le
doc: |
  Treasure Co., Ltd.'s Nintendo DS multi-resource archive (Bleach: The Blade
  of Fate, Bleach: Dark Souls, Bangai-O Spirits). A member count and a table
  of `(offset, size)` pairs, optional padding to a 4- or 8-byte boundary, then
  the payloads: 2D screen maps and sprites (`.bg4`, `.bg8`), palettes and
  scripts.
seq:
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
