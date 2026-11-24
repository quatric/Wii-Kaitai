meta:
  id: ubi_loc
  title: Ubisoft .loc string table (Sleepover Party)
  file-extension: loc
  endian: le
doc: First name is the column title "String ID"; first text is that column's title.
seq:
  - id: count
    type: u4
  - id: names
    type: strz
    encoding: ASCII
    repeat: expr
    repeat-expr: count
  - id: texts
    type: utf16_strz
    repeat: expr
    repeat-expr: count
types:
  utf16_strz:
    seq:
      - id: chars
        type: u2
        repeat: until
        repeat-until: _ == 0
