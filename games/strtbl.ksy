meta:
  id: strtbl
  title: Rockstar Table Tennis .strtbl string table
  file-extension: strtbl
  endian: le
doc: |
  Key block {u32 flags 0x200, u32 count, count * {u32 length, key, NUL}} ends at
  the first language offset; each language block is {u32 count, count * {u32
  hash, u16 1, u32 length, font tag, u32 chars, UTF-16LE text, 10 zero bytes}}.
seq:
  - id: block_count
    type: u4
  - id: block_offsets
    type: u4
    repeat: expr
    repeat-expr: block_count
    doc: Unused languages point at the end of the file.
  - id: key_block
    type: key_block
types:
  key_block:
    seq:
      - id: flags
        type: u4
        doc: 0x200.
      - id: count
        type: u4
      - id: keys
        type: key
        repeat: expr
        repeat-expr: count
  key:
    seq:
      - id: length
        type: u4
      - id: text
        size: length
        type: str
        encoding: ASCII
      - id: nul
        size: 1
