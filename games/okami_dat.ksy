meta:
  id: okami_dat
  title: Clover / Okami offset-table container (.dat, .bin, .i)
  endian: be
doc: |
  Clover / Okami (Wii) offset-table container (`.dat`, `.bin`, `.i` inside the
  `_data` AFS archives). `count` member offsets (strictly increasing, 0x20
  aligned, the first behind the table); a member runs to the next offset and the
  last to the end of the file.
seq:
  - id: count
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
