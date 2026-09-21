meta:
  id: play_rec
  file-extension: dat
  endian: be
doc: >-
  Fixed 0xc8-byte Wii play-record layout divided into a 0x48-byte identity/
  timing block and a 0x80-byte trailing data block.  Both blocks begin with
  independent integrity words.  The layout is complete, but the checksum
  algorithm and meanings of the trailing words have not been recovered.
seq:
  - id: part1
    type: part1
    doc: Identity, timing, and title block at offsets 0x00..0x47.
  - id: part2
    type: part2
    doc: Trailing 0x80-byte data block at offsets 0x48..0xc7.
types:
  part1:
    seq:
      - id: checksum
        type: u4
        doc: Integrity word for the first 0x48-byte block; coverage is unknown.
      - id: name
        type: str
        size: 40
        encoding: UTF-16BE
        doc: Fixed 20-code-unit UTF-16BE name field, including any NUL padding.
      - id: pad1
        type: u4
        doc: Unidentified 32-bit field at offset 0x2c within the first block.
      - id: ticks_boot
        type: u8
        doc: 64-bit boot-time/tick value at offset 0x30 within the first block.
      - id: ticks_last
        type: u8
        doc: 64-bit most-recent-time/tick value at offset 0x38 within the first block.
      - id: title_id
        type: u4
        doc: 32-bit title/application identifier at offset 0x40 within the first block.
  part2:
    seq:
      - id: checksum
        type: u4
        doc: Integrity word for the trailing 0x80-byte block; coverage is unknown.
      - id: data
        type: u4
        repeat: expr
        repeat-expr: 31
        doc: >-
          Thirty-one retained big-endian words.  They occupy the remainder of
          the record and are not described as padding because their individual
          meanings are presently unknown.
