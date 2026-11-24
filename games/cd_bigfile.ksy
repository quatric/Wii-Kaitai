meta:
  id: cd_bigfile
  title: Crystal Dynamics bigfile (.wii-w)
  endian: be
doc: |
  Crystal Dynamics `bigfile.000.wii-w` / `chapterN.000.wii-w` (Tomb Raider:
  Anniversary). File data follows from the next 0x800 boundary, stored back to
  back in table order with every entry padded to 0x800 (records with identical
  `{size, aux}` share the first copy) so the last one ends exactly at the end of
  the archive. Names are only stored as hashes.
seq:
  - id: count
    type: u4
  - id: name_hashes
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Ascending.
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: len_data
        type: u4
      - id: aux
        type: u4
      - id: locale_mask
        type: u4
      - id: zero
        type: u4
