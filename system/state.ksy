meta:
  id: state
  file-extension: dat
  endian: be
doc: >-
  Fixed 32-byte Wii state record.  The four leading bytes are an integrity
  value followed by four one-byte launch/disc-state controls and six u32
  words.  This definition records the complete observed wire layout, but the
  checksum algorithm and the meanings of the final six words have not been
  recovered; they are intentionally retained as typed opaque values rather
  than labeled as padding.
seq:
  - id: checksum
    type: u4
    doc: >-
      Integrity value for the record at offset 0x00.  Its coverage and
      algorithm are not established by the available implementation, so a
      writer must preserve or independently recompute it rather than assume a
      standard CRC.
  - id: flags
    type: u1
    doc: Launch-state flags byte at offset 0x04; individual bit assignments are unknown.
  - id: type
    type: u1
    doc: State-record type byte at offset 0x05; known values have not been catalogued.
  - id: discstate
    type: u1
    doc: Disc-state selector byte at offset 0x06.
  - id: returnto
    type: u1
    doc: Return-target selector byte at offset 0x07.
  - id: unknown
    type: u4
    repeat: expr
    repeat-expr: 6
    doc: >-
      Six 32-bit values occupying offsets 0x08..0x1f.  These are stored as
      big-endian words because their semantics are presently unknown, not
      because they are known to be padding.
