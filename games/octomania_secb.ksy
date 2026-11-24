meta:
  id: octomania_secb
  title: Octomania secB scene container (.sec)
  file-extension: sec
  endian: be
doc: |
  Octomania `secB` scene / demo container. A table of records and a name pool
  follow the header; the payload is a run of standard Nintendo NW4R files (RSAR /
  RSTM / RWSD / RBNK / RSEQ, `bres`, RLYT / RLAN / RFNT / RFNA, `REFF`) on 0x800
  byte boundaries after the table, either stored as is or packed with a token
  stream (token `b < 0x80` = b literal bytes, `b >= 0x80` = `(b & 0x7F) + 1`
  copies of the next byte; packed members are skipped by nintoolbox).
seq:
  - id: magic
    contents: secB
  - id: one
    type: u4
  - id: data_start
    type: u4
    doc: 0x800.
  - id: len_table
    type: u4
  - id: alignment
    type: u4
