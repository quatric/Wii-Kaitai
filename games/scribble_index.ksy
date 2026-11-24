meta:
  id: scribble_index
  title: Scribblenauts Unlimited index.bin
  file-extension: bin
  endian: be
doc: |
  Scribblenauts Unlimited (Wii U / PC) `index.bin` for the `*.p` packages
  (big-endian on Wii U; see GMWare ScribbleUnpacker for the little-endian
  layout). Pack 0xFF means no data. `zlevel` 0 is raw, otherwise a zlib stream
  (the pack stores one extra trailer byte after each stream, which `stored`
  already counts). The table carries no names.
seq:
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
  - id: num_packs
    type: u4
  - id: pack_names
    type: pack_name
    repeat: expr
    repeat-expr: num_packs
types:
  entry:
    seq:
      - id: pack
        type: u1
      - id: zlevel
        type: u1
      - id: offset
        type: u4
      - id: len_stored
        type: u4
      - id: len_unpacked
        type: u4
  pack_name:
    seq:
      - id: len_name
        type: u1
      - id: name
        type: str
        size: len_name
        encoding: ASCII
