meta:
  id: iarc
  title: IARC archive (.iaa, .arc, .wad)
  endian: be
doc: |
  `IARC` archive (Benjamin Blumchen: Törööö im Zoo, Wii, and sibling
  Tierpension-engine titles). The directory is a Nintendo LZ11 stream (type
  byte 0x11 + 24-bit LE size) at 0x20, holding `count` 0x48-byte records (see
  `record`); every member is itself an LZ11 stream at `data_base + offset`.
seq:
  - id: magic
    contents: IARC
  - id: len_file
    type: u4
  - id: num_entries
    type: u4
  - id: dir_record_size
    type: u4
    doc: 0x80.
  - id: data_base
    type: u4
  - id: one
    type: u4
  - id: constant
    type: u4
    doc: 0x3400.
  - id: unknown
    type: u4
  - id: directory_lz11
    size-eos: true
    doc: LZ11 directory followed by the members; decode before applying `record`.
types:
  record:
    doc: One decoded directory record.
    seq:
      - id: offset
        type: u4
        doc: From `data_base`.
      - id: len_packed
        type: u4
      - id: len_unpacked
        type: u4
      - id: name
        size: 60
        type: strz
        encoding: ASCII
