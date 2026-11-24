meta:
  id: cc2_fpk
  title: CyberConnect2 fpack (.fpk)
  file-extension: fpk
  endian: be
doc: |
  CyberConnect2-style `fpack` `.fpk` (Naruto Shippuden: Clash of Ninja
  Revolution III, Tatsunoko vs. Capcom; not the Traveller's Tales `.fpk`).
  A member whose stored and unpacked sizes are equal is stored as is; otherwise
  it is Sega PRS with the bits read most significant first: flag 1 = literal;
  0 then 1 = long copy (big-endian u16, offset in the top 13 bits minus 0x2000,
  length in the low 3 bits plus 2, or a length byte plus 1 when those are 0, and
  0 ends the stream); 0 then 0 = short copy (two length bits plus 2, one offset
  byte minus 0x100).
seq:
  - id: id
    type: u4
  - id: num_entries
    type: u4
  - id: table_offset
    type: u4
    doc: 0x10.
  - id: len_file
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name
        size: 0x24
        type: strz
        encoding: ASCII
        doc: Relative path.
      - id: offset
        type: u4
      - id: len_stored
        type: u4
      - id: len_unpacked
        type: u4
