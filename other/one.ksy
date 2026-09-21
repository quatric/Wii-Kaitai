meta:
  id: one
  endian: be
  title: Sonic Storybook ONE archive (Sonic and the Secret Rings / Black Knight)
doc: |
  Sonic Team Storybook-series ".one" archive, as written by
  CreateONEArchive() in lib-one.c. A fixed 16-byte header followed by
  a flat table of 48-byte entries (32-byte NUL-padded name, PRS-body
  offset, compressed size, decompressed size); member data is
  Sonic Team's PRS-variant LZ stream (EncodeStorybookPRS), not
  modeled here.
seq:
  - id: num_entries
    type: u4
  - id: data_start
    type: u4
    doc: Offset of the first member's compressed data (== 16 + num_entries*48).
  - id: total_size
    type: u4
  - id: marker
    type: u4
    doc: 0 = Secret Rings, 0xffffffff = Black Knight.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name
        type: str
        size: 32
        encoding: ASCII
        terminator: 0
      - id: data_offset
        type: u4
      - id: compressed_size
        type: u4
      - id: decompressed_size
        type: u4
    instances:
      body:
        pos: data_offset
        size: compressed_size
        io: _root._io
