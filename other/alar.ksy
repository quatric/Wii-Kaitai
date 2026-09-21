meta:
  id: alar
  file-extension: alar
  endian: le
  title: Jump Ultimate Stars archive (ALAR)
doc: |
  A small flat archive from *Jump Ultimate Stars* (DS). A fixed 16-byte
  header is followed by a table of 16-byte entries; each entry's payload
  offset/size are known (bytes 4..8 and 8..12 of the entry), the rest of
  the entry layout is not reverse-engineered here -- the reference tool
  only ever decodes entry 0.

  `num_files` overlaps two layouts at header offset 6: for `archive_type`
  2 it is a u2, for `archive_type` 3 it is a u4. The header is a fixed 16
  bytes either way; the entry table starts right after it.
seq:
  - id: magic
    contents: "ALAR"
  - id: archive_type
    type: u1
    enum: alar_type
  - id: unknown1
    type: u1
  - id: header_tail
    size: 10
    doc: |
      Bytes 6..16 of the header: `num_files` (u2 for type 2, u4 for type
      3, both little-endian) plus trailing padding, kept raw here -- see
      `num_files`.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
instances:
  num_files:
    value: |
      archive_type == alar_type::type3
        ? header_tail[0] | (header_tail[1] << 8) | (header_tail[2] << 16) | (header_tail[3] << 24)
        : header_tail[0] | (header_tail[1] << 8)
types:
  entry:
    seq:
      - id: unknown1
        type: u4
        doc: Not reverse-engineered; unused by the reference extractor.
      - id: ofs_body
        type: u4
      - id: len_body
        type: u4
      - id: unknown2
        type: u4
        doc: Not reverse-engineered; unused by the reference extractor.
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        if: len_body > 0
enums:
  alar_type:
    2: type2
    3: type3
