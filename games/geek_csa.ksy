meta:
  id: geek_csa
  title: GEEK archive (.csa)
  file-extension: csa
  endian: le
doc: |
  `GEEK` archive (Barbie Horse Adventures - Riding Camp `data.csa`, 755 MB).
  Names are backslash paths.
seq:
  - id: magic
    contents: GEEK
  - id: constant_0x100
    type: u4
  - id: data_start
    type: u4
  - id: flags
    type: u4
  - id: num_files
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: name
        size: 128
        type: strz
        encoding: ASCII
