meta:
  id: mula_mtp
  title: Angry Birds Trilogy archive (.MTP)
  file-extension: mtp
  endian: le
doc: |
  Angry Birds Trilogy (Wii) `Data/**/*.MTP`. NUL-terminated backslash paths
  (e.g. `DATA\CLASSIC\AUDIO\...\X.WAV`) follow the table, then the members back
  to back, each padded to 4 bytes, starting at the 4-aligned end of the name pool.
seq:
  - id: magic
    contents: MULA
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
  - id: len_name_pool
    type: u4
types:
  entry:
    seq:
      - id: len_data
        type: u4
      - id: name_offset
        type: u4
