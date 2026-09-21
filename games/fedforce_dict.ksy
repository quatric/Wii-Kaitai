meta:
  id: fedforce_dict
  file-extension: dict
  endian: le
  title: Metroid Prime Federation Force .dict (3DS, Next Level Games)
doc: |
  Little-endian block/reference table used by *Metroid Prime: Federation
  Force* (3DS, Next Level Games), ported from nintoolbox's
  `lib-fedforce.c` (`ScanFedForceDict`). Reimplemented from
  KillzXGaming/Metroid-Fed-Force-Dumper, not copied.

  The identifier at offset 0 aliases `0x5824F3A9` in either byte order
  (shared with the Luigi's Mansion 2/3 family); FedForce specifically is
  the variant that additionally reads `0x297B947A` at offset 16 in either
  byte order. Layout: `id` (u32), `flags` (u16), `compressed` (u8), a pad
  byte, `largest` block size (u32), then `num_blocks`/`num_refs`/
  `num_strings` byte counts and a pad byte, followed by `num_refs`
  16-byte reference records, `num_blocks` 16-byte block records, and
  `num_strings` NUL-terminated external-extension strings.
seq:
  - id: id
    type: u4
    doc: 0x5824F3A9 (LE) / 0xA9F32458 (BE) for the wider LM2/LM3 family.
  - id: flags
    type: u2
  - id: compressed
    type: u1
  - id: pad0
    type: u1
  - id: largest
    type: u4
    doc: Largest block size, in bytes.
  - id: num_blocks
    type: u1
  - id: num_refs
    type: u1
  - id: num_strings
    type: u1
  - id: pad1
    type: u1
  - id: fed_marker
    type: u4
    doc: 0x297B947A (LE) / BE identifies the FedForce variant specifically.
  - id: refs
    type: file_table_ref
    repeat: expr
    repeat-expr: num_refs
  - id: blocks
    type: block
    repeat: expr
    repeat-expr: num_blocks
  - id: strings
    type: strz
    encoding: ASCII
    repeat: expr
    repeat-expr: num_strings
types:
  file_table_ref:
    seq:
      - id: name_hash
        type: u4
      - id: file_section_count
        type: u2
      - id: file_count
        type: u2
      - id: block_indices
        size: 8
        doc: 8 block indices (FedForce); LM3 uses 16 and does not fit this record size.
  block:
    seq:
      - id: offset
        type: u4
      - id: decomp_size
        type: u4
      - id: comp_size
        type: u4
      - id: flags
        type: u4
    instances:
      source_index:
        value: (flags >> 16) & 0xff
