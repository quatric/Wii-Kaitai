meta:
  id: kylotonn
  title: Kylotonn FVRT data archive
  file-extension: dat
  endian: le
doc: |
  My Body Coach, Cocoto Festival (`BodyCoaching.dat`, `cocoto.dat`). Chunks are
  {tag, u32 LE size}; VERS and NAME first. Member data starts at 0x1c; the
  payload ends with the 8-byte "SARR" index header. TEXT: {u32 count, u32 0}
  then 32-byte entries; TBUF (at TEXT + its size) is the NUL-separated name pool.
seq:
  - id: magic
    contents: FVRT
  - id: hash
    type: u4
  - id: vers_tag
    contents: VERS
  - id: vers_size
    type: u4
    doc: 12.
  - id: vers_value
    type: u4
    doc: 0x1900.
  - id: file_tag
    contents: FILE
  - id: payload_size
    type: u4
    doc: Member data starts at 0x1c.
instances:
  index_pos:
    value: 0x1c + payload_size
types:
  text_chunk:
    seq:
      - id: count
        type: u4
      - id: zero
        type: u4
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: count
  entry:
    seq:
      - id: m1_a
        type: s4
      - id: m1_b
        type: s4
      - id: hash
        type: u4
      - id: m1_c
        type: s4
      - id: flags
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
        doc: From 0x1c.
      - id: name_pool_offset
        type: u4
