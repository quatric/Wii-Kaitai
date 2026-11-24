meta:
  id: sega_msb
  title: SEGA MSCR script binary (.msb, Sakura Wars So Long My Love)
  file-extension: msb
  endian: le
doc: |
  Body = file + header size (0x20, or 0x10). 8 words {hash, hash, u32 offset of
  the word table, u32 word count, u32 offset of the entry table (0x20, 0x18 in
  the two files with a 0x10-byte header), u32 entry count, 0, 0}; an entry is
  {u32 id, u32 argument block offset, u32 argument word count, u32 code offset}
  (all relative to the body); code is a stream of 16-bit instruction words that
  runs to the next code offset (the last to the word table). Words with bit 15
  set are immediate pushes (opcode = word & 0xf000, argument = word & 0xfff);
  opcodes 0x10..0x14 are literal pushes with a 32-bit inline value; 0x0001 ends a
  statement.
seq:
  - id: head
    type: head
instances:
  entries:
    pos: head.entry_table_offset
    type: entry
    repeat: expr
    repeat-expr: head.entry_count
types:
  head:
    seq:
      - id: hash_a
        type: u4
      - id: hash_b
        type: u4
      - id: word_table_offset
        type: u4
      - id: word_count
        type: u4
      - id: entry_table_offset
        type: u4
      - id: entry_count
        type: u4
      - id: zero
        size: 8
  entry:
    seq:
      - id: id
        type: u4
      - id: argument_block_offset
        type: u4
      - id: argument_word_count
        type: u4
      - id: code_offset
        type: u4
