meta:
  id: wii_res_arc
  title: '"wii" resource archive (Petanque Master .ARC)'
  file-extension: arc
  endian: be
doc: |
  Resource archive with magic `wii\0` (Petanque Master and Petanque Pro on
  Wii: `0_MENUBASE.ARC` ... `PARK.ARC`, `MUSIC.ARC`, `*SOUNDS.ARC`; seven more
  titles share the magic). Verified on 105 retail files.

  The 0x20-byte records sit immediately before the name offset table, at
  `names_offset - 0x20 * n_entries`; the i-th name belongs to the i-th
  record. Record offsets are relative to `data_base` when the first record's
  offset is 0 (the level and menu archives) and absolute otherwise (the
  `*SOUNDS.ARC` banks). nintoolbox writes members as `<name>.t<type>`.
seq:
  - id: magic
    contents: ['wii', 0]
  - id: zero_04
    type: u4
  - id: w2
    type: u4
  - id: num_entries
    type: u4
  - id: flag
    type: u4
  - id: names_offset
    type: u4
    doc: Start of an array of `num_entries` absolute name offsets.
  - id: data_base
    type: u4
instances:
  records:
    pos: names_offset - 0x20 * num_entries
    type: record
    repeat: expr
    repeat-expr: num_entries
  name_offsets:
    pos: names_offset
    type: u4
    repeat: expr
    repeat-expr: num_entries
types:
  record:
    seq:
      - id: runtime0
        type: u4
      - id: type
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
      - id: id
        type: u4
      - id: zero_14
        type: u4
      - id: record_size
        type: u4
        doc: Always 0x20.
      - id: runtime1
        type: u4
