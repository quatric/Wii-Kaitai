meta:
  id: puzzler_lpz
  title: Puzzler Collection PZPK record pack (.lpz)
  file-extension: lpz
  endian: le
doc: |
  Each record runs to the next offset (the last to EOF). ".txz" text packs are
  "ZZ" + locale name, a 0x0a byte, u32 LE decompressed size and one zlib stream.
seq:
  - id: magic
    contents: PZPK
  - id: x10
    type: u4
  - id: count
    type: u4
  - id: index_bytes
    type: u4
    doc: count * 16.
  - id: index
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: index
        type: u4
      - id: unk
        size: 4
      - id: data_offset
        type: u4
      - id: flags
        size: 4
