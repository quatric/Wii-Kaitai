meta:
  id: krome_rkv
  title: Krome Studios RK33 archive (.rkv)
  file-extension: rkv
  endian: be
doc: |
  Krome "RK33" resource archives (Happy Feet Two, Legend of Spyro: The Eternal
  Night, Owls of Ga'Hoole). A 0x100-byte header, member data, and a table of
  0x60-byte entries at `toc_offset`. When `stored_size == size` the member is
  raw; otherwise the block starts with a method byte `2` followed by an LZF
  stream.
seq:
  - id: name
    type: strz
    size: 0x40
    encoding: ASCII
  - id: toc_offset
    type: u8
    doc: 0x40 in the header.
  - id: version
    type: u4
    doc: 6.
  - id: count
    type: u4
  - id: toc_size
    type: u4
  - id: magic
    contents: 'RK33'
  - id: header_rest
    size: 0x100 - 0x58
instances:
  toc:
    pos: toc_offset
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        type: strz
        size: 0x40
        encoding: ASCII
      - id: time
        type: u8
      - id: data_offset
        type: u8
      - id: crc
        type: u4
      - id: size
        type: u4
      - id: stored_size
        type: u4
      - id: zero
        type: u4
    instances:
      is_compressed:
        value: stored_size != size
      data:
        pos: data_offset
        size: stored_size
        io: _root._io
