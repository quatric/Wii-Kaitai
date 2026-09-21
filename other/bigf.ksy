meta:
  id: bigf
  file-extension: big
  endian: le
  title: Electronic Arts BIGF asset archive
doc: |
  EA's flat "BIG" archive as shipped for the Wii (`BIGF`). A tiny fixed
  header is followed by a variable-length member table -- each entry a
  big-endian (offset, size) pair plus a NUL-terminated name -- and the
  table is closed off by a literal `L234` marker, padded with zeros up to
  the (four-byte aligned) start of the data region.

  The header's own size field is little-endian while every offset/size in
  the member table is big-endian; that split is native to the format, not
  a reconstruction artifact.
seq:
  - id: magic
    contents: "BIGF"
  - id: len_file
    type: u4
    doc: Total archive size.
  - id: num_entries
    type: u4be
  - id: ofs_data
    type: u4be
    doc: Start of the payload region; also where the member table's padding ends.
instances:
  entries:
    pos: 16
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: ofs_body
        type: u4be
        doc: Absolute offset of this member's data.
      - id: len_body
        type: u4be
      - id: name
        type: strz
        encoding: ASCII
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
