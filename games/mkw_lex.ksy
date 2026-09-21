meta:
  id: mkw_lex
  file-extension: lex
  application: Mario Kart Wii
  endian: be
doc: |
  LE-CODE (Wiimms SZS Tools) LEX parameter file. Ported from
  lex_header_t / lex_element_t in lib-lex.h / lib-lex.c of the SZS
  project (https://szs.wiimm.de/). Holds one or more independent
  "sections" (elements), each identified by a 4-byte magic and carrying
  its own payload -- primary settings (SET1), developer flags (DEV1),
  countdown timers (CTDN), position-tracker hide rules (HIPT), random
  item/next-link rules (RITP) and test scenarios (TEST). Distinct from
  the plain-text "#LEX" dump variant, which this definition does not
  cover.
seq:
  - id: magic
    contents: "LE-X"
  - id: major_version
    type: u2
  - id: minor_version
    type: u2
  - id: file_size
    type: u4
    doc: Size of this file (header + all elements).
  - id: element_off
    type: u4
    doc: Offset of the first element, 32-bit aligned.
instances:
  elements:
    pos: element_off
    type: element
    repeat: until
    repeat-until: _io.pos >= file_size or _.size_of_data == 0
    doc: |
      Elements are stored consecutively, each 32-bit aligned; walking
      stops at end of file. There is no explicit element count.
types:
  element:
    seq:
      - id: magic
        type: u4
        enum: section_magic
      - id: size_of_data
        type: u4
        doc: Size of `data`, this 8-byte header excluded.
      - id: data
        size: size_of_data
enums:
  section_magic:
    0x44455631: dev1 # "DEV1" developer settings
    0x53455431: set1 # "SET1" primary settings
    0x4354444e: ctdn # "CTDN" countdown settings
    0x48495054: hipt # "HIPT" hide position tracker
    0x52495450: ritp # "RITP" random next-links @KMP:ITPH
    0x54455354: test # "TEST" test scenario settings
