meta:
  id: opoona_opkg
  title: Opoona OPKG package
  endian: le
doc: |
  Opoona (Wii, ArtePiazza) `OPKG` package: no magic. It is usually found as
  the unpacked payload of an `SL01` wrapper (`SL01`, u32 unpacked size, u32
  packed size, plain LZO1X stream). Stored names are tail-truncated paths such
  as `racter/p109/p109_01.mdl`.
seq:
  - id: num_entries
    type: u4
  - id: header_size_a
    type: u2
    doc: 0x20.
  - id: header_size_b
    type: u2
    doc: 0x20.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: name
        size: 24
        type: strz
        encoding: ASCII
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
