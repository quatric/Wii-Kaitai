meta:
  id: lz11_dat_tbl
  title: Deer Drive / Kid Adventures resource.tbl (decompressed)
  file-extension: tbl
  endian: be
doc: |
  `resource.tbl` of the `resource.dat` + `resource.tbl` pairs of Deer Drive / Kid
  Adventures style budget Wii games. The `.tbl` is itself LZ11 compressed; this
  describes its unpacked form. The `.dat` starts with a zero-padded `dummy`
  header (0x20 bytes) followed by LZ11 compressed (or stored) blocks. All zero
  for unused slots; the table has no names.
seq:
  - id: zero
    type: u4
  - id: len_table
    type: u4
  - id: reserved
    size: 0x18
  - id: slots
    type: slot
    repeat: eos
types:
  slot:
    seq:
      - id: offset
        type: u4
        doc: Into the .dat.
      - id: len_compressed
        type: u4
      - id: len_unpacked
        type: u4
