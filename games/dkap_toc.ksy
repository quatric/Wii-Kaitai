meta:
  id: dkap_toc
  title: Ubisoft vdb_NGC BIGFILE TOC (Totally Spies)
  file-extension: toc
  endian: le
doc: |
  `BIGFILEn.TOC` for `BIGFILEn.DAT` (Totally Spies! Totally Party, Wii;
  Ubisoft `vdb_NGC` repository). The first member is id 1 at offset 0 with the
  size from the head; the rest follow back to back. A trailing 0xAAAAAAAA fill
  pads the TOC. `DKAP` members are LZO1X packed (`DKAP`, u32 LE unpacked size,
  stream at +8).
seq:
  - id: count
    type: u4
  - id: version
    type: u4
    doc: 1.
  - id: first_type_hash
    type: u4
  - id: first_size
    type: u4
  - id: padding
    size: 0x24 - 16
  - id: records
    type: record
    repeat: expr
    repeat-expr: count - 1
types:
  record:
    seq:
      - id: group
        type: u4
      - id: id
        type: u4
      - id: type_hash
        type: u4
      - id: len_data
        type: u4
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: Four equal copies.
      - id: flag
        type: u4
