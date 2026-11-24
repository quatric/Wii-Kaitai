meta:
  id: re4_drs
  title: Resident Evil 4 Wii Edition container (.drs, .das)
  file-extension: drs
  endian: be
doc: |
  Resident Evil 4 (Wii Edition) `*.drs` / `*.das`. A 0x20-byte Shift-JIS title,
  then 0x20-byte entries terminated by type 0xFFFFFFFF; the first block starts at
  0x400, blocks follow each other (up to 0xF bytes padding) and end at the end of
  the file. Type 4 blocks are nested containers of the same layout.
seq:
  - id: title
    size: 0x20
    type: strz
    encoding: SJIS
  - id: entries
    type: entry
    repeat: until
    repeat-until: _.type == 0xffffffff
types:
  entry:
    seq:
      - id: type
        type: u4
      - id: len_data
        type: u4
        if: type != 0xffffffff
      - id: zero
        type: u4
        if: type != 0xffffffff
      - id: offset
        type: u4
        if: type != 0xffffffff
      - id: padding
        size: 16
        if: type != 0xffffffff
