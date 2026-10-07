meta:
  id: hog
  title: HOG archive (Ultimate Band, Hannah Montana)
  file-extension: hog
  endian: le
doc: |
  "HOG" archives from Ultimate Band and Disney's Hannah Montana (all
  little-endian). A 0x20-byte header, `n_entries` 16-byte records, a name
  table of NUL-terminated names with backslash path separators, and then the member
  data. Members are stored uncompressed.

  Electronic Arts `SHOC` streams may also carry the `.hog` extension; those are
  a different, chunked format.
seq:
  - id: version
    type: u2
    doc: Always 1.
  - id: unknown_02
    type: u2
    doc: Always 2.
  - id: header_size
    type: u4
    doc: Always 0x20.
  - id: zero_08
    type: u4
  - id: hash
    type: u4
  - id: num_entries
    type: u4
  - id: names_size
    type: u4
  - id: pad_14
    size: header_size - 0x18
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name_offset
        type: u4
        doc: Absolute.
      - id: data_offset
        type: u4
        doc: Absolute.
      - id: size
        type: u4
      - id: name_hash
        type: u4
    instances:
      name:
        pos: name_offset
        type: strz
        encoding: ASCII
        io: _root._io
      body:
        pos: data_offset
        size: size
        io: _root._io
