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

  The extractor requires the declared whole-file length to equal the
  actual length, 1..0x100000 entries, and a data-region offset within the
  file. Each member name must terminate before ofs_data and be a valid
  relative output path; each payload must begin at or after ofs_data and
  end within the file. When bytes remain between the final name and
  ofs_data, they must begin with L234 and the rest must be zero padding.
  The reader also accepts the degenerate case where the last name ends
  exactly at ofs_data, leaving no marker region.

  The nintoolbox writer always adds L234, aligns ofs_data to four bytes,
  and packs payloads consecutively with no inter-member alignment. Its
  directory-scan order is not guaranteed to reproduce retail ordering;
  these are reconstruction choices, not constraints on existing BIGFs.
seq:
  - id: magic
    contents: "BIGF"
  - id: len_file
    type: u4
    doc: Total archive size.
  - id: num_entries
    type: u4be
    doc: Number of variable-length member records.
  - id: ofs_data
    type: u4be
    doc: Start of the payload region; also where the member table's padding ends.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
  - id: table_tail
    type: table_tail_t
    size: ofs_data - _io.pos
    if: ofs_data > _io.pos
    doc: Optional L234 terminator and zero padding up to ofs_data.
types:
  table_tail_t:
    seq:
      - id: marker
        contents: "L234"
        doc: End-of-table marker present when there is a table-tail region.
      - id: padding
        type: u1
        repeat: eos
        valid:
          eq: 0
        doc: Zero padding before the first payload.
  entry:
    seq:
      - id: ofs_body
        type: u4be
        doc: Absolute offset of this member's data.
      - id: len_body
        type: u4be
        doc: Declared member byte length.
      - id: name
        type: strz
        encoding: ASCII
        doc: NUL-terminated relative output path.
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        doc: Uncompressed raw payload at its absolute file offset.
