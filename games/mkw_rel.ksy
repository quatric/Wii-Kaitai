meta:
  id: mkw_rel
  endian: be
  title: Mario Kart Wii StaticR.rel (Nintendo REL module)
doc: |
  Nintendo REL relocatable module header (StaticR.rel), per
  `rel_header_t`/`rel_sect_info_t`/`rel_imp_t`/`rel_data_t` in
  lib-staticr.h.
seq:
  - id: id
    type: u4
  - id: unknown_04
    type: u4
  - id: unknown_08
    type: u4
  - id: num_sections
    type: u4
  - id: section_offset
    type: u4
  - id: mod_name_offset
    type: u4
  - id: mod_name_len
    type: u4
  - id: version
    type: u4
  - id: bss_size
    type: u4
  - id: reloc_offset
    type: u4
  - id: imp_offset
    type: u4
  - id: imp_size
    type: u4
  - id: flags
    type: u4
  - id: prolog
    type: u4
  - id: epilog
    type: u4
  - id: unknown_3c
    type: u4
  - id: align_all
    type: u4
    doc: Version >= 2 only.
  - id: align_bss
    type: u4
    doc: Version >= 2 only.
  - id: fix_size
    type: u4
    doc: Version >= 3 only.
instances:
  sections:
    type: sect_info_t
    repeat: expr
    repeat-expr: num_sections
    pos: section_offset
  imports:
    type: imp_t
    repeat: expr
    repeat-expr: imp_size / 8
    pos: imp_offset
types:
  sect_info_t:
    seq:
      - id: raw_offset
        type: u4
        doc: Low bit set marks the section executable; 0 offset means uninitialized (BSS).
      - id: size
        type: u4
    instances:
      is_executable:
        value: raw_offset & 1
      offset:
        value: raw_offset & ~1
  imp_t:
    seq:
      - id: kind
        type: u4
        doc: 1 = internal, 0 = external.
      - id: offset
        type: u4
  reloc_entry_t:
    seq:
      - id: skip
        type: u2
      - id: reloc_type
        type: u1
      - id: section
        type: u1
      - id: address
        type: u4
