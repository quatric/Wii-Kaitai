meta:
  id: nandbootinfo
  endian: be
doc: >-
  Fixed 0x1020-byte NAND boot-information record.  It contains a compact
  launch header and a 0x1000-byte argument area.  The established field names
  describe the loader-facing layout; checksum coverage and several control
  values have not been recovered, so this definition retains them rather than
  calling them padding.
seq:
  - id: checksum
    type: u4
    doc: >-
      Integrity word at offset 0x00.  The algorithm and covered range are not
      established; preserve or independently recompute it when modifying a
      record.
  - id: argsoff
    type: u4
    doc: >-
      Offset/selector for the argument area at offset 0x04.  Its exact unit
      and interpretation have not been confirmed, so it is exposed as the
      original big-endian word rather than used to slice argbuf.
  - id: unknown
    type: u1
    doc: Unknown control byte at offset 0x08.
  - id: unknown2
    type: u1
    doc: Unknown control byte at offset 0x09.
  - id: apptype
    type: u1
    doc: >-
      Application-source type: 0x80 when booted from DVD and 0x81 when booted
      from NAND.
  - id: titletype
    type: u1
    doc: Title-type/control byte at offset 0x0b; values are not fully catalogued.
  - id: launchcode
    type: u4
    doc: Launch-control word at offset 0x0c.
  - id: unknown3
    type: u4
    repeat: expr
    repeat-expr: 2
    doc: Two unrecovered 32-bit launch-header words at offsets 0x10 and 0x14.
  - id: launcher
    type: u8
    doc: 64-bit launcher/title identifier at offset 0x18.
  - id: argbuf
    size: 4096
    doc: >-
      Fixed 0x1000-byte boot argument buffer at offset 0x20.  It is raw bytes
      because its contents and argsoff addressing vary by launch context.
