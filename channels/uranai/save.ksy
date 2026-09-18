meta:
  id: uranai_save
  title: Today & Tomorrow Channel - NAND save data
  application: Today & Tomorrow Channel
  file-extension: dat
  endian: be
doc: |
  The channel's save file: 0x1C8 (456) bytes, read back as 0x1E0 (the size is rounded up to
  the NAND block). It is written by 0x80042178 (buffer builder 0x800EAF3C) and read by the
  state machine at 0x80044D00.

  Integrity, in the order the loader applies it: the 32-bit sum of every byte from offset
  4 up to 0x1C8 (0x8004574C; a plain byte sum, no CRC) is compared with the first word.
  A mismatch discards the whole file (count becomes 0). Each record's 8-byte create-id is
  then looked up in the Mii Channel database (0x801941F0); a Mii that no longer exists
  gets index 0xFFFF and is dropped, which is why erasing a Mii in the Mii Channel also
  removes it here.

  Only the fields below are ever written: the record's first 0x10 bytes plus the four
  counters. The empty-slot template (0x800456EC) zeroes everything else, and no code
  reads the remaining bytes or the settings block.
seq:
  - id: checksum
    type: u4
  - id: mii_count
    type: u4
    doc: 0 to 6
  - id: settings
    size: 0x40
    doc: copied from game data +0xC4 verbatim; not interpreted by any code found
  - id: miis
    type: mii
    repeat: expr
    repeat-expr: 6
    doc: the first `mii_count` slots are in use, the rest is the zero template
types:
  mii:
    seq:
      - id: create_id
        size: 8
        doc: the Mii's RFL create-id
      - id: birth_year
        type: u2
      - id: birth_month
        type: u1
      - id: birth_day
        type: u1
      - id: unknown_0c
        size: 4
      - id: score_counters
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: best and next-day total scores (0x8004307C rolls them over); source of the Message Board "highest total luck" post
      - id: reserved
        size: 0x20
