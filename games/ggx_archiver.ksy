meta:
  id: ggx_archiver
  title: Cave/Milestone GGXArchiver container
  file-extension: bin
  endian: le
doc: |
  Cave/Milestone `GGXArchiver` container (Radirgy Noa, Wii; `sc_*.bin`,
  `stage*.bin`, `player*.bin`). Each member is Gage byte-pair-encoding blocks
  (256-entry pair table in the usual run-length-coded form, u16 BE block size,
  then the packed bytes) whose output is the loose file format of the disc
  (Illvelo-style `XIBG` PVR textures, `LTJN` / `MCJN` / `MDMN` Ninja files).
seq:
  - id: magic
    contents: ['GGXArchiver1.00', 0]
  - id: count
    type: u4
  - id: count_again
    type: u4
  - id: padding
    size: 8
  - id: names
    size: 32
    type: strz
    encoding: ASCII
    repeat: expr
    repeat-expr: count
    doc: Windows backslashes in the original names.
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: index
        type: u4
      - id: one0
        type: u4
      - id: len_decompressed
        type: u4
      - id: len_compressed
        type: u4
      - id: one1
        type: u4
      - id: offset
        type: u4
        doc: From the end of the record table.
