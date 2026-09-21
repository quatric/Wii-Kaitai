meta:
  id: str
  file-extension: .bin
  endian: be
doc: >-
  TV no Tomo's HDPK `001B` string-index package.  The file-wide directory
  convention is important: every stored table or target offset is relative to
  byte 0x20, so Kaitai resolves it as `stored_offset + 32`.  The definition
  models the pointer and two-offset text-table directories; the string
  encoding and the meanings of several common HDPK header words remain
  unrecovered.

seq:
  - id: magic
    contents: "HDPK"
    doc: HDPK container signature.
  - id: type
    contents: "001B"
    doc: File-kind code for this TV-guide package.
  - id: file_length
    type: u4
    doc: Producer-declared complete file size.
  - id: pointer_table_offset
    type: u4
    doc: Offset, relative to 0x20, of the pointer-table directory.
  - id: pointer_table_size
    type: u4
    doc: Number of 4-byte entries in pointer_table.
  - id: unknown
    type: u4
    doc: Common HDPK header word at 0x14; semantics not recovered.
  - id: footer_size
    type: u4
    doc: Producer-declared footer length at offset 0x18.
  - id: unknown1
    type: u4
    doc: Unrecovered common HDPK header word at 0x1c.
  - id: unknown2
    type: u4
    doc: Unrecovered common HDPK header word at 0x20.
  - id: unknown3
    type: u4
    doc: Unrecovered common HDPK header word at 0x24.
  - id: unknown4
    type: u4
    doc: Unrecovered common HDPK header word at 0x28.
  - id: unknown5
    type: u4
    doc: Unrecovered common HDPK header word at 0x2c.
  - id: unknown6
    type: u4
    doc: Unrecovered common HDPK header word at 0x30.
  - id: unknown7
    type: u4
    doc: Unrecovered common HDPK header word at 0x34.
  - id: number_of_text_tables
    type: u4
    doc: Number of two-offset text-table entries.
  - id: text_table_offset
    type: u4
    doc: Offset, relative to 0x20, of the text-table directory.
    
instances:
  pointer_table:
    pos: pointer_table_offset + 32
    type: pointer_table
    repeat: expr
    repeat-expr: pointer_table_size
    doc: Array of 0x20-relative pointers to 32-bit target values.

  text_table:
    pos: text_table_offset + 32
    type: text_table
    repeat: expr
    repeat-expr: number_of_text_tables
    doc: Array of paired text references; their target string encoding is unknown.
    
types:
  text_table:
    seq:
      - id: text_1_offset
        type: u4
        doc: First text reference, stored relative to byte 0x20.
      - id: text_2_offset
        type: u4
        doc: Second text reference, stored relative to byte 0x20.
  pointer_table:
    seq:
      - id: value
        type: u4
        doc: Target offset stored relative to byte 0x20.
        
    instances:
      target:
        pos: value + 32
        type: u4
        doc: 32-bit value resolved at value + 0x20.
