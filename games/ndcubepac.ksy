meta:
  id: ndcubepac
  endian: be
  title: Nd Cube Wii U flat container (Mario Party 10 / Animal Crossing amiibo Festival)
doc: |
  Nd Cube Wii U flat file container ("PAC\0"), as read by
  ExtractPACArchive() in lib-nintendo-archives.c. Big-endian
  throughout. Each member's payload is ordinary zlib-compressed data
  (standard 0x78 0xda header) at `file_start`, inflating to exactly
  `size` bytes; despite an earlier assumption it is not encrypted.
seq:
  - id: magic
    contents: "PAC\0"
  - id: header_length
    type: u4
  - id: reserved1
    type: u4
  - id: overall_file_start
    type: u4
  - id: pac_size
    type: u4
  - id: language_count
    type: u4
  - id: unknown1
    type: u4
  - id: unknown2
    type: u4
  - id: file_total
    type: u4
  - id: reserved2
    size: 0xc
  - id: language_start
    type: u4
  - id: file_header_start
    type: u4
  - id: string_start
    type: u4
  - id: overall_file_start2
    type: u4
instances:
  languages:
    type: language_entry
    repeat: expr
    repeat-expr: language_count
    pos: language_start
  entries:
    type: file_entry
    repeat: expr
    repeat-expr: file_total
    pos: file_header_start
types:
  language_entry:
    seq:
      - id: language_name
        type: u4
      - id: unknown
        type: u4
      - id: language_file_count
        type: u4
      - id: language_offsets_start
        type: u4
  file_entry:
    seq:
      - id: filename_start
        type: u4
      - id: unknown1
        type: u4
      - id: extension_start
        type: u4
      - id: unknown2
        type: u4
      - id: file_start
        type: u4
      - id: size
        type: u4
      - id: zsize
        type: u4
      - id: zsize2
        type: u4
      - id: reserved
        size: 0x10
    instances:
      name:
        io: _root._io
        pos: filename_start
        type: strz
        encoding: ASCII
  strz:
    seq:
      - id: value
        type: str
        terminator: 0
        encoding: ASCII
