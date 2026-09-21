meta:
  id: termpod
  endian: le
  title: Terminal Reality POD3/POD4/POD5 archive (Nickelodeon Dance, Wii)
doc: |
  Terminal Reality style POD3/POD4/POD5 archive, per lib-termpod.h
  (ported from github.com/jopadan/termpod). Only stored members are
  meaningfully extractable in the reference reader; compressed ones
  are skipped there.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"POD3"', '"POD4"', '"POD5"']
  - id: header_crc
    type: u4
  - id: unknown_08
    size: 0x58 - 8
  - id: num_entries
    type: u4
  - id: unknown_5c
    size: 0x108 - 0x5c
  - id: entry_offset
    type: u4
  - id: unknown_10c
    size: 4
  - id: names_size
    type: u4
instances:
  is_pod3:
    value: magic == "POD3"
  entries:
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
    pos: entry_offset
types:
  entry_t:
    doc: 20 bytes for POD3, 28 bytes for POD4/POD5.
    seq:
      - id: name_offset
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
      - id: uncompressed_size
        type: u4
        if: _root.magic != "POD3"
      - id: compression_level
        type: u4
        if: _root.magic != "POD3"
      - id: timestamp
        type: u4
      - id: crc
        type: u4
