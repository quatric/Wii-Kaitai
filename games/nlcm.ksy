meta:
  id: nlcm
  title: NLCM file index (Rune Factory Frontier)
  file-extension: bin
  endian: be
doc: |
  `NLCM` file index (Rune Factory Frontier, Wii `RUNEFACTORY.bin` +
  `RUNEFACTORY.dat`). Entries sit at 0x800-aligned offsets of the `.dat` file
  and carry no names. Each entry's 64-bit values are stored as low/high words.
seq:
  - id: magic
    contents: NLCM
  - id: header_size
    type: u4
    doc: 0x38.
  - id: len_name
    type: u4
    doc: 0x14.
  - id: count
    type: u4
  - id: num_data_files
    type: u4
  - id: data_file_name
    size: len_name
    type: strz
    encoding: ASCII
  - id: reserved
    size: 0x0c
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: len_data
        type: u4
      - id: zero0
        type: u4
      - id: offset
        type: u4
      - id: zero1
        type: u4
